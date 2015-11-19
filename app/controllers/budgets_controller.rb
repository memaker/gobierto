class BudgetsController < ApplicationController
  def index
    @filter = BudgetFilter.new(params)

    respond_to do |format|
      format.html
      format.json do
        @paginated_result = @filter.apply
      end
    end
  end
end
