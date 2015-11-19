class BudgetsController < ApplicationController
  def index
    @filter = BudgetFilter.new(params)
    @paginated_result = @filter.apply

    respond_to do |format|
      format.html
      format.json
    end
  end
end
