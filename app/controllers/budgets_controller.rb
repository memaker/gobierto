class BudgetsController < ApplicationController
  def index
    return if params[:year].nil?

    @budgets = BudgetFilter.new.filter(params)
  end
end
