class GobiertoSites::BudgetsController < GobiertoSites::ApplicationController
  before_action :load_place, :load_year

  def index
    @kind = GobiertoBudgets::BudgetLine::EXPENSE
    @area_name = GobiertoBudgets::BudgetLine::FUNCTIONAL

    @place_budget_lines = GobiertoBudgets::BudgetLine.where(place: @place, level: 1, year: @year, kind: @kind, area_name: @area_name).all
  end

  private

  def load_place
    @place = @site.place
    render_404 and return if @place.nil?
  end

  def load_year
    if params[:year].nil?
      redirect_to gobierto_sites_budgets_path(GobiertoBudgets::SearchEngineConfiguration::Year.last)
    else
      @year = params[:year]
    end
  end

end
