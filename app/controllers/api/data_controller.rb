class Api::DataController < ApplicationController

  def treemap
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
              must: [
                {term: { ine_code: params[:ine_code] }},
                {term: { level: params[:level] }},
                {term: { kind: params[:kind] }},
                {term: { year: params[:year] }}
              ]
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
    total_budget_data = total_budget_data(year, 'amount')
    total_budget_data_previous_year = total_budget_data(year - 1, 'amount')

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
    total_budget_data = total_budget_data(year, 'amount_per_inhabitant')
    total_budget_data_previous_year = total_budget_data(year - 1, 'amount_per_inhabitant')

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

  private

  def total_budget_data(year, field)
    query = {
      query: {
        filtered: {
          query: {
            match_all: {}
          },
          filter: {
            bool: {
              must: [
                {term: { level: 1 }},
                {term: { kind: params[:kind] }},
                {term: { year: year }}
              ]
            }
          }
        }
      },
      size: 0,
      "aggs": {
        "place_total_budget": {
          "terms": {
            "field": "ine_code",
            size: 100_000
          },
          "aggs": {
            "budget_sum": {
              "sum": {
                "field": field
              }
            }
          }
        }
      }
    }

    response = SearchEngine.client.search index: BudgetLine::INDEX, type: params[:type], body: query
    Rails.logger.info "#{response['took']} ms"
    buckets = response['aggregations']['place_total_budget']['buckets'].map{|v| [v['key'], v['budget_sum']['value']] }.sort_by{|h| h.last }.reverse

    if row = buckets.detect{|v| v.first == params[:ine_code].to_i }
      value = row.last
    end

    position = buckets.index(row) + 1 rescue nil

    return {
      value: value,
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
