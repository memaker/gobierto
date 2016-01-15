class Api::DataController < ApplicationController
  include ApplicationHelper

  caches_page :total_budget, :population, :total_budget_per_inhabitant, :lines, :budget,
              :budget_per_inhabitant, :budget_percentage_over_total, :budget_percentage_over_province

  def total_budget
    year = params[:year].to_i
    total_budget_data = total_budget_data(year, 'total_budget')
    total_budget_data_previous_year = total_budget_data(year - 1, 'total_budget', false)
    position = total_budget_data[:position].to_i

    respond_to do |format|
      format.json do
        render json: {
          title: 'Gasto total',
          value: format_currency(total_budget_data[:value]),
          delta_percentage: helpers.number_with_precision(delta_percentage(total_budget_data[:value], total_budget_data_previous_year[:value]), precision: 2),
          ranking_position: position,
          ranking_total_elements: helpers.number_with_precision(total_budget_data[:total_elements], precision: 0),
          ranking_url: places_ranking_path(year,'G','economic','amount', page: Ranking.page_from_position(position), anchor: position)
        }.to_json
      end
    end
  end

  def population
    year = params[:year].to_i
    population_data = Population.ranking_hash_for(params[:ine_code].to_i,year)
    position = population_data[:position]

    respond_to do |format|
      format.json do
        render json: {
          title: 'Habitantes',
          value: helpers.number_with_delimiter(population_data[:value], precision: 0, strip_insignificant_zeros: true),
          delta_percentage: helpers.number_with_precision(delta_percentage(population_data[:value], population_data[:value]), precision: 2),
          ranking_position: position,
          ranking_total_elements: helpers.number_with_precision(population_data[:total_elements], precision: 0),
          ranking_url: population_ranking_path(year, page: Ranking.page_from_position(position), anchor: position)
        }.to_json
      end
    end
  end

  def total_budget_per_inhabitant
    year = params[:year].to_i
    total_budget_data = total_budget_data(year, 'total_budget_per_inhabitant')
    total_budget_data_previous_year = total_budget_data(year - 1, 'total_budget_per_inhabitant', false)
    position = total_budget_data[:position].to_i

    respond_to do |format|
      format.json do
        render json: {
          title: 'Gasto por habitante',
          value: helpers.number_to_currency(total_budget_data[:value], precision: 0, strip_insignificant_zeros: true),
          delta_percentage: helpers.number_with_precision(delta_percentage(total_budget_data[:value], total_budget_data_previous_year[:value]), precision: 2),
          ranking_position: position,
          ranking_total_elements: helpers.number_with_precision(total_budget_data[:total_elements], precision: 0),
          ranking_url: places_ranking_path(year,'G','economic','amount_per_inhabitant', page: Ranking.page_from_position(position), anchor: position)
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

    @category_name = @kind == 'G' ? 'Gasto' : 'Ingreso'

    budget_data = budget_data(@year, 'amount')
    budget_data_previous_year = budget_data(@year - 1, 'amount', false)
    position = budget_data[:position].to_i

    respond_to do |format|
      format.json do
        render json: {
          title: @category_name,
          value: format_currency(budget_data[:value]),
          delta_percentage: helpers.number_with_precision(delta_percentage(budget_data[:value], budget_data_previous_year[:value]), precision: 2),
          ranking_position: position,
          ranking_total_elements: helpers.number_with_precision(budget_data[:total_elements], precision: 0),
          ranking_url: places_ranking_path(@year,@kind,@area,'amount',@code,page: Ranking.page_from_position(position), anchor: position)
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
    position = budget_data[:position].to_i

    respond_to do |format|
      format.json do
        render json: {
          title: "#{@category_name} por habitante",
          value: format_currency(budget_data[:value]),
          delta_percentage: helpers.number_with_precision(delta_percentage(budget_data[:value], budget_data_previous_year[:value]), precision: 2),
          ranking_position: position,
          ranking_total_elements: helpers.number_with_precision(budget_data[:total_elements], precision: 0),
          ranking_url: places_ranking_path(@year,@kind,@area,'amount_per_inhabitant',@code,page: Ranking.page_from_position(position), anchor: position)
        }.to_json
      end
    end
  end

  def budget_percentage_over_total
    @year = params[:year].to_i
    @area = params[:area]
    @kind = params[:kind]
    @code = params[:code]

    begin
      result = SearchEngine.client.get index: BudgetLine::INDEX, type: @area, id: [params[:ine_code],@year,@code,@kind].join('/')
      amount = result['_source']['amount'].to_f

      result = SearchEngine.client.get index: BudgetTotal::INDEX, type: BudgetTotal::TYPE, id: [params[:ine_code], @year].join('/')
      total_amount = result['_source']['total_budget'].to_f

      percentage = (amount.to_f * 100)/total_amount
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      percentage = 0
    end

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

    begin
      result = SearchEngine.client.get index: BudgetLine::INDEX, type: @area, id: [params[:ine_code],@year,@code,@kind].join('/')
      amount = result['_source']['amount'].to_f
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      amount = 0
    end

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
          title: "Dif. con media provincial",
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

    begin
      value = SearchEngine.client.get index: BudgetLine::INDEX, type: @area, id: id
      value = value['_source'][field]
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      value = 0
    end

    return {
      value: value,
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
      response = SearchEngine.client.search index: BudgetTotal::INDEX, type: BudgetTotal::TYPE, body: query
      Rails.logger.info "#{response['took']} ms"
      buckets = response['hits']['hits'].map{|h| h['_id']}
      position = buckets.index(id) + 1
    else
      buckets = []
      position = 0
    end

    begin
      value = SearchEngine.client.get index: BudgetTotal::INDEX, type: BudgetTotal::TYPE, id: id
      value = value['_source'][field]
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      value = 0
    end

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
