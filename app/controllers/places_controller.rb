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
    @kind = (params[:kind] == 'income' ? BudgetLine::INCOME : BudgetLine::EXPENSE)
    @level = (params[:parent_code].present? ? params[:parent_code].length + 1 : 1)

    options = { ine_code: @place.id, level: @level, year: @year, kind: @kind, type: @area_name }
    options[:parent_code] = params[:parent_code] if params[:parent_code].present?
    
    @budget_lines = BudgetLine.search(options) 
     
    respond_to do |format|
      format.html
      format.js
    end

  end

  # def expense
  #   @budget_lines = BudgetLine.search(ine_code: @place.id, level: 1, year: @year, kind: BudgetLine::EXPENSE, type: @area_name)
  # end

  # def income
  #   @budget_lines = BudgetLine.search(ine_code: @place.id, level: 1, year: @year, kind: BudgetLine::INCOME, type: 'economic')
  # end

  private
  def get_params
    @place = INE::Places::Place.find_by_slug params[:slug]
    @area_name = params[:area] || 'economic'
    @year = params[:year]
  end
end
