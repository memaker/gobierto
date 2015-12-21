class Api::DataController < ApplicationController

  def treemap
    options = [
      {term: { ine_code: params[:ine_code] }},
      {term: { kind: params[:kind] }},
      {term: { year: params[:year] }}
    ]

    if params[:code].nil?
      options.push({term: { level: params[:level] }})
    else
      options.push({term: { parent_code: params[:code] }})
    end

    query = {
      sort: [
        { amount: { order: 'desc' } }
      ],
      query: {
        filtered: {
          query: {
            match_all: {}
          },
          filter: {
            bool: {
              must: options
            }
          }
        }
      },
      size: 10_000
    }

    areas = params[:type] == 'economic' ? EconomicArea : FunctionalArea

    response = SearchEngine.client.search index: BudgetLine::INDEX, type: params[:type], body: query
    children_json = response['hits']['hits'].map do |h|
      {
        name: areas.all_items[params[:kind]][h['_source']['code']],
        code: h['_source']['code'],
        budget: h['_source']['amount'],
        budget_per_inhabitant: h['_source']['amount_per_inhabitant']
      }
    end

    respond_to do |format|
      format.json do
        render json: {
          name: params[:type],
          children: children_json
        }.to_json
      end
    end
  end

  def total_budget
    year = params[:year].to_i
    total_budget_data = total_budget_data(year, 'total_budget')
    total_budget_data_previous_year = total_budget_data(year - 1, 'total_budget', false)

    respond_to do |format|
      format.json do
        render json: {
          title: 'Gasto total',
          value: helpers.number_to_currency(total_budget_data[:value], precision: 0, strip_insignificant_zeros: true),
          delta_percentage: helpers.number_with_precision(delta_percentage(total_budget_data[:value], total_budget_data_previous_year[:value]), precision: 2),
          ranking_position: total_budget_data[:position],
          ranking_total_elements: helpers.number_with_precision(total_budget_data[:total_elements], precision: 0)
        }.to_json
      end
    end
  end

  def population
    year = params[:year].to_i
    population_data = population_data(year)

    respond_to do |format|
      format.json do
        render json: {
          title: 'Habitantes',
          value: helpers.number_with_delimiter(population_data[:value], precision: 0, strip_insignificant_zeros: true),
          delta_percentage: helpers.number_with_precision(delta_percentage(population_data[:value], population_data[:value]), precision: 2),
          ranking_position: population_data[:position],
          ranking_total_elements: helpers.number_with_precision(population_data[:total_elements], precision: 0)
        }.to_json
      end
    end
  end

  def budget_per_inhabitant
    year = params[:year].to_i
    total_budget_data = total_budget_data(year, 'total_budget_per_inhabitant')
    total_budget_data_previous_year = total_budget_data(year - 1, 'total_budget_per_inhabitant', false)

    respond_to do |format|
      format.json do
        render json: {
          title: 'Gasto por habitante',
          value: helpers.number_to_currency(total_budget_data[:value], precision: 0, strip_insignificant_zeros: true),
          delta_percentage: helpers.number_with_precision(delta_percentage(total_budget_data[:value], total_budget_data_previous_year[:value]), precision: 2),
          ranking_position: total_budget_data[:position],
          ranking_total_elements: helpers.number_with_precision(total_budget_data[:total_elements], precision: 0)
        }.to_json
      end
    end
  end

  def lines
    @place = INE::Places::Place.find(params[:ine_code])
    data_line = Data::Lines.new place: @place, year: params[:year], what: params[:what]

    respond_to do |format|
      format.json do
        render json: data_line.generate_json
      end
    end
  end

  private

  def total_budget_data(year, field, ranking = true)
    query = {
      sort: [
        { field.to_sym => { order: 'desc' } }
      ],
      query: {
        filtered: {
          query: {
            match_all: {}
          },
          filter: {
            bool: {
              must: [
                {term: { year: year }}
              ]
            }
          }
        }
      },
      size: 10_000,
    }

    id = "#{params[:ine_code]}/#{year}"

    if ranking
      response = SearchEngine.client.search index: BudgetLine::INDEX, type: 'total-budget', body: query
      Rails.logger.info "#{response['took']} ms"
      buckets = response['hits']['hits'].map{|h| h['_id']}
      position = buckets.index(id) + 1
    else
      buckets = []
      position = 0
    end

    value = SearchEngine.client.get index: BudgetLine::INDEX, type: 'total-budget', id: id

    return {
      value: value['_source'][field],
      position: position,
      total_elements: buckets.length
    }
  end

  def population_data(year)
    query = {
      sort: [
        { value: { order: 'desc' } }
      ],
      query: {
        filtered: {
          query: {
            match_all: {}
          },
          filter: {
            bool: {
              must: [
                {term: { year: year }}
              ]
            }
          }
        }
      },
      size: 10_000
    }

    response = SearchEngine.client.search index: 'data', type: 'population', body: query
    Rails.logger.info "#{response['took']} ms"
    buckets = response['hits']['hits'].map{ |h| h['_source'] }

    if row = buckets.detect{|v| v['ine_code'] == params[:ine_code].to_i }
      value = row['value']
    end

    position = buckets.index(row) + 1 rescue nil

    return {
      value: value,
      position: position,
      total_elements: buckets.length
    }
  end

  def delta_percentage(value, old_value)
     ((value.to_f - old_value.to_f)/old_value.to_f) * 100
  end

end
