class PlacesController < ApplicationController
  before_action :get_params

  def show
    @income_lines = BudgetLine.search(ine_code: @place.id, level: 1, year: @year, kind: BudgetLine::INCOME, type: 'economic')
    @expense_lines = BudgetLine.search(ine_code: @place.id, level: 1, year: @year, kind: BudgetLine::EXPENSE, type: @area_name)

    respond_to do |format|
      format.html
      format.js
    end

  end

  def budget
    @level = (params[:parent_code].present? ? params[:parent_code].length + 1 : 1)

    options = { ine_code: @place.id, level: @level, year: @year, kind: @kind, type: @area_name }
    options[:parent_code] = params[:parent_code] if params[:parent_code].present?

    @budget_lines = BudgetLine.search(options) 

    respond_to do |format|
      format.html
      format.json do
        data_line = Data::Treemap.new place: @place, year: @year, kind: @kind, type: @area_name, parent_code: params[:parent_code]
        render json: data_line.generate_json
      end
      format.js
    end
  end

  # /places/compare/:slug_list/:year/:kind/:area
  def compare
    @places = get_places params[:slug_list]
    @totals = BudgetTotal.for @places.map(&:id), @year
    @population = Population.for @places.map(&:id), @year

    @compared_level = (params[:parent_code].present? ? params[:parent_code].length + 1 : 1)
    options = { ine_codes: @places.map(&:id), year: @year, kind: @kind, level: @compared_level, type: @area_name }

    if @compared_level > 1
      @budgets_and_ancestors = BudgetLine.compare_with_ancestors(options.merge(parent_code: params[:parent_code]))
      @budgets_compared = @budgets_and_ancestors.select {|bl| bl['parent_code'] == params[:parent_code]}
      @parent_compared = @budgets_and_ancestors.select {|bl| bl['code'] == params[:parent_code] }
    else
      @budgets_compared = @budgets_and_ancestors = BudgetLine.compare(options)
    end
  end

  def ranking
    per_page = 25
    page = params[:page] ? params[:page].to_i : 1

    @compared_level = params[:code].length

    @places_data = budget_data(@year, 'amount', page, per_page)
  end

  private

  def get_params
    @place = INE::Places::Place.find_by_slug params[:slug] if params[:slug].present?
    @kind = ( %w{income i}.include?(params[:kind].downcase) ? BudgetLine::INCOME : BudgetLine::EXPENSE ) unless params[:action] == 'show'
    @area_name = params[:area] || 'economic'
    @year = params[:year]
    @code = params[:code] if params[:code].present?
  end

  def get_places(slug_list)
    slug_list.split(':').map {|slug| INE::Places::Place.find_by_slug slug}
  end

  def budget_data(year, field, page, per_page)
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

    response = SearchEngine.client.search index: BudgetLine::INDEX, type: @area_name, body: query
    Rails.logger.info "#{response['took']} ms"
    results = response['hits']['hits'].map{|h| h['_source']}

    return {
      elements: results[(page - 1)*per_page..page*per_page],
      total_elements: results.length
    }
  end
end
