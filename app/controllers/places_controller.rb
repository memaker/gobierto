class PlacesController < ApplicationController
  def show
    @place = INE::Places::Place.find params[:id]
    @area_name = params[:area] || 'economic'
    @income_lines = BudgetLine.search(ine_code: @place.id, level: 1, year: 2015, kind: BudgetLine::INCOME, type: 'economic')
    @expense_lines = BudgetLine.search(ine_code: @place.id, level: 1, year: 2015, kind: BudgetLine::EXPENSE, type: @area_name)
  end
end
