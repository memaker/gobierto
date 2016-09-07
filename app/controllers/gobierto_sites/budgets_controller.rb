class GobiertoSites::BudgetsController < GobiertoSites::ApplicationController
  before_action :load_place, :load_year

  def index
    @kind = GobiertoBudgets::BudgetLine::INCOME
    @area_name = GobiertoBudgets::BudgetLine::ECONOMIC

    @site_stats = SiteStats.new site: @site, year: @year

    @top_income_budget_lines = GobiertoBudgets::TopBudgetLine.limit(5).where(year: @year, place: @site.place, kind: GobiertoBudgets::BudgetLine::INCOME).all
    @top_expense_budget_lines = GobiertoBudgets::TopBudgetLine.limit(5).where(year: @year, place: @site.place, kind: GobiertoBudgets::BudgetLine::EXPENSE).all
    @place_budget_lines = GobiertoBudgets::BudgetLine.where(place: @place, level: 1, year: @year, kind: @kind, area_name: @area_name).all

    @sample_budget_lines = (@top_income_budget_lines + @top_expense_budget_lines).sample(3)
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
      @year = params[:year].to_i
    end
  end

end
