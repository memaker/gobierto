class PlacesController < ApplicationController
  def show
    @place = INE::Places::Place.find_by_slug params[:slug]
    @area_name = params[:area] || 'economic'
    @year = params[:year]
    @income_lines = BudgetLine.search(ine_code: @place.id, level: 1, year: @year, kind: BudgetLine::INCOME, type: 'economic')
    @expense_lines = BudgetLine.search(ine_code: @place.id, level: 1, year: @year, kind: BudgetLine::EXPENSE, type: @area_name)

    respond_to do |format|
      format.html
      format.js
    end

  end
end
