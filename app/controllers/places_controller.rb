class PlacesController < ApplicationController
  before_action :get_params
  before_action :solve_income_area_mismatch, except: [:show]

  def show
    render_404 and return if @place.nil?
    if @year.nil?
      redirect_to place_path(@place, 2015) and return
    end

    @income_lines = BudgetLine.search(ine_code: @place.id, level: 1, year: @year, kind: BudgetLine::INCOME, type: 'economic')
    @expense_lines = BudgetLine.search(ine_code: @place.id, level: 1, year: @year, kind: BudgetLine::EXPENSE, type: @area_name)
    @no_data = @income_lines['hits'].empty?

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
    @filters = params[:f]
    if @place && params[:page].nil?

      place_position = Ranking.place_position(year: @year, ine_code: @place.id, code: @code, kind: @kind, area: @area_name, field: @variable, filters: @filters)

      page = Ranking.page_from_position(place_position)
      redirect_to url_for(params.merge(page: page)) and return
    end

    @per_page = Ranking.per_page
    @page = params[:page] ? params[:page].to_i : 1
    render_404 and return if @page <= 0

    @compared_level = params[:code] ? (params[:code].include?('-') ? params[:code].split('-').first.length : params[:code].length) : 0
    @ranking_items = Ranking.query({year: @year, variable: @variable, page: @page, code: @code, kind: @kind, area_name: @area_name, filters: @filters})
    
    respond_to do |format|
      format.html
      format.js
    end
  end

  private

  def get_params
    @place = INE::Places::Place.find_by_slug params[:slug] if params[:slug].present?
    @place = INE::Places::Place.find params[:ine_code] if params[:ine_code].present?
    @kind = ( %w{income i}.include?(params[:kind].downcase) ? BudgetLine::INCOME : BudgetLine::EXPENSE ) if action_name != 'show' && params[:kind]
    @kind ||= BudgetLine::EXPENSE if action_name == 'ranking'
    @area_name = params[:area] || 'functional'
    @year = params[:year]
    @code = code_from_params(params[:code]) if params[:code].present?
    if params[:variable].present?
      @variable = params[:variable]
      render_404 and return unless valid_variables.include?(@variable)
    end
  end

  def solve_income_area_mismatch
    area = (params[:area].present? ? params[:area].downcase : '')
    kind = (params[:kind].present? ? params[:kind].downcase : '')
    if %w{income i}.include?(kind) && area == 'functional'
      redirect_to url_for params.merge(area: 'economic', kind: 'I') and return
    end
  end

  def get_places(slug_list)
    slug_list.split(':').map {|slug| INE::Places::Place.find_by_slug slug}
  end

  def valid_variables
    ['amount','amount_per_inhabitant','population']
  end

end
