class BudgetsController < ApplicationController
  def index
    return if params[:year].nil?

    @filter = BudgetFilter.new(params)
    @budgets = @filter.filter
  end
end
