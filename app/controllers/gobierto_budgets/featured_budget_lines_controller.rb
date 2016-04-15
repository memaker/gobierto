module GobiertoBudgets
  class FeaturedBudgetLinesController < GobiertoBudgets::ApplicationController
    def show
      @place = INE::Places::Place.find_by_slug(params[:id])
      @year = params[:year]
      @area_name = 'functional'

      @kind = GobiertoBudgets::BudgetLine::EXPENSE
      results = BudgetLine.search({
          kind: @kind, year: @year, ine_code: @place.id,
          type: @area_name, range_hash: {
            level: {ge: 3},
            amount_per_inhabitant: { gt: 0 }
          }
      })['hits']

      @code = results.sample['code'] if results.any?

      respond_to do |format|
        format.js do
          @code.present? ? render('show') : render(nothing: true)
        end
      end
    end
  end
end