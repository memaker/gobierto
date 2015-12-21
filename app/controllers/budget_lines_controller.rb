class BudgetLinesController < ApplicationController
  def show
    @place = INE::Places::Place.find_by_slug params[:slug]
    @year = params[:year]
    @code = params[:code]
    @kind = ( %w{income i}.include?(params[:kind].downcase) ? BudgetLine::INCOME : BudgetLine::EXPENSE )
    @area_name = 'economic'

    @parent_line = BudgetLine.find(ine_code: @place.id, code: @code, year: @year, kind: @kind)
    @budget_lines = BudgetLine.search(ine_code: @place.id, parent_code: @code, year: @year, kind: @kind)

    pp @parent_line
  end
end
