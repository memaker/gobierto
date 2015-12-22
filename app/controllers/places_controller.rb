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
    @places = get_places(params[:slug_list])
    options = { ine_codes: @places.map(&:id), level: 1, year: @year, kind: @kind, type: @area_name }
    @budgets_compared = BudgetLine.compare(options)
  end

  private
  def get_params
    @place = INE::Places::Place.find_by_slug params[:slug] unless params[:action] == 'compare'
    @kind = ( %w{income i}.include?(params[:kind].downcase) ? BudgetLine::INCOME : BudgetLine::EXPENSE ) unless params[:action] == 'show'
    @area_name = params[:area] || 'economic'
    @year = params[:year]
  end

  def get_places(slug_list)
    slug_list.split(':').map {|slug| INE::Places::Place.find_by_slug slug}
  end
end
