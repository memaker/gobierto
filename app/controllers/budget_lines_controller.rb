class BudgetLinesController < ApplicationController
  def show
    @place = INE::Places::Place.find_by_slug params[:slug]
    @year = params[:year]
    @code = code_from_params(params[:code])
    @kind = ( %w{income i}.include?(params[:kind].downcase) ? BudgetLine::INCOME : BudgetLine::EXPENSE )
    @area_name = params[:area] || 'economic'

    options = { ine_code: @place.id, year: @year, kind: @kind, type: @area_name }

    @budget_line = BudgetLine.new year: @year, kind: @kind, place_id: @place.id, area_name: @area_name, code: @code

    @parent_line = BudgetLine.find(options.merge(code: @code))
    @budget_lines = BudgetLine.search(options.merge(parent_code: @code))
  end
end
