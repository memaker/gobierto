class BudgetsController < ApplicationController
  def index
    return if params[:year].nil?

    @filter = BudgetFilter.new(params)
    @budget_lines = @filter.apply
  end
end
