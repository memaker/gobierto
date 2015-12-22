class Api::DataController < ApplicationController
  include ApplicationHelper

  def total_budget
    year = params[:year].to_i
    total_budget_data = total_budget_data(year, 'total_budget')
    total_budget_data_previous_year = total_budget_data(year - 1, 'total_budget', false)

    respond_to do |format|
      format.json do
        render json: {
          title: 'Gasto total',
          value: format_currency(total_budget_data[:value]),
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

  def total_budget_per_inhabitant
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
    data_line = Data::Lines.new place: @place, year: params[:year], what: params[:what], kind: params[:kind], code: params[:code], area: params[:area]

    respond_to do |format|
      format.json do
        render json: data_line.generate_json
      end
    end
  end

  def budget
    @year = params[:year].to_i
    @area = params[:area]
    @kind = params[:kind]
    @code = params[:code]

    areas = @area == 'economic' ? EconomicArea : FunctionalArea
    @category_name = areas.all_items[@kind][@code]

    budget_data = budget_data(@year, 'amount')
    budget_data_previous_year = budget_data(@year - 1, 'amount', false)

    respond_to do |format|
      format.json do
        render json: {
          title: ActionController::Base.helpers.truncate(@category_name, length: 35),
          value: format_currency(budget_data[:value]),
          delta_percentage: helpers.number_with_precision(delta_percentage(budget_data[:value], budget_data_previous_year[:value]), precision: 2),
          ranking_position: budget_data[:position],
          ranking_total_elements: helpers.number_with_precision(budget_data[:total_elements], precision: 0)
        }.to_json
      end
    end
  end

  def budget_per_inhabitant
    @year = params[:year].to_i
    @area = params[:area]
    @kind = params[:kind]
    @code = params[:code]

    @category_name = @kind == 'G' ? 'Gasto' : 'Ingreso'

    budget_data = budget_data(@year, 'amount_per_inhabitant')
    budget_data_previous_year = budget_data(@year - 1, 'amount_per_inhabitant', false)

    respond_to do |format|
      format.json do
        render json: {
          title: "#{@category_name} por habitante",
          value: format_currency(budget_data[:value]),
          delta_percentage: helpers.number_with_precision(delta_percentage(budget_data[:value], budget_data_previous_year[:value]), precision: 2),
          ranking_position: budget_data[:position],
          ranking_total_elements: helpers.number_with_precision(budget_data[:total_elements], precision: 0)
        }.to_json
      end
    end
  end

  def budget_percentage_over_total
    @year = params[:year].to_i
    @area = params[:area]
    @kind = params[:kind]
    @code = params[:code]

    result = SearchEngine.client.get index: BudgetLine::INDEX, type: @area, id: [params[:ine_code],@year,@code,@kind].join('/')
    amount = result['_source']['amount'].to_f

    result = SearchEngine.client.get index: BudgetLine::INDEX, type: 'total-budget', id: [params[:ine_code], @year].join('/')
    total_amount = result['_source']['total_budget'].to_f

    percentage = (amount.to_f * 100)/total_amount

    respond_to do |format|
      format.json do
        render json: {
          title: "Porcentaje sobre el total",
          value: "#{helpers.number_with_precision(percentage, precision: 2, strip_insignificant_zeros: true)}%"
        }.to_json
      end
    end
  end

  def budget_percentage_over_province
    @year = params[:year].to_i
    @area = params[:area]
    @kind = params[:kind]
    @code = params[:code]
    @place = INE::Places::Place.find(params[:ine_code])

    result = SearchEngine.client.get index: BudgetLine::INDEX, type: @area, id: [params[:ine_code],@year,@code,@kind].join('/')
    amount = result['_source']['amount'].to_f

    query = {
      query: {
        filtered: {
          query: {
            match_all: {}
          },
          filter: {
            bool: {
              must: [ 
                {term: { province_id: @place.province_id }},
                {term: { code: @code }},
                {term: { year: @year }},
                {term: { kind: @kind }}
              ]
            }
          }
        }
      },
      size: 10_000,
      "aggs": {
        "budget_sum": {
          "sum": {
            "field": "amount"
          }
        }
      }
    }

    response = SearchEngine.client.search index: BudgetLine::INDEX, type: @type, body: query
    mean = response['aggregations']['budget_sum']['value'] / response['hits']['hits'].length

    percentage = (amount.to_f * 100)/mean

    respond_to do |format|
      format.json do
        render json: {
          title: "Diferencia con la media provincial",
          value: "#{helpers.number_with_precision(percentage, precision: 2, strip_insignificant_zeros: true)}%"
        }.to_json
      end
    end
  end

  private

  def budget_data(year, field, ranking = true)
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
                {term: { year: year }},
                {term: { code: @code }},
                {term: { kind: @kind }}
              ]
            }
          }
        }
      },
      size: 10_000,
    }

    id = "#{params[:ine_code]}/#{year}/#{@code}/#{@kind}"

    if ranking
      response = SearchEngine.client.search index: BudgetLine::INDEX, type: @area, body: query
      Rails.logger.info "#{response['took']} ms"
      buckets = response['hits']['hits'].map{|h| h['_id']}
      position = buckets.index(id) + 1
    else
      buckets = []
      position = 0
    end

    value = SearchEngine.client.get index: BudgetLine::INDEX, type: @area, id: id

    return {
      value: value['_source'][field],
      position: position,
      total_elements: buckets.length
    }
  end


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
