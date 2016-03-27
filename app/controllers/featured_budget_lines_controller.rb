class FeaturedBudgetLinesController < ApplicationController
  def show
    @place = INE::Places::Place.find_by_slug(params[:id])
    @year = params[:year]

    @area_name = 'functional'
    klass = FunctionalArea
    @kind = BudgetLine::EXPENSE

    sample = klass.all_items[@kind].keys.select{|k| k.length == 3}
    @code = nil
    times = 10
    i = 0
    while @code.nil? || times < 10
      i+=1
      @code = sample.sample
      budget_line = BudgetLine.search({
        kind: @kind, year: @year, ine_code: @place.id,
        code: @code
      })
      if budget_line.present?
        break
      else
        @code = nil
      end
    end

    respond_to do |format|
      format.js
    end
  end
end
