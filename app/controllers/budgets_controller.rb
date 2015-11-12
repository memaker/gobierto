class BudgetsController < ApplicationController
  def index
    @filter = BudgetFilter.new(params)
    @budget_lines = @filter.apply
  end
end
