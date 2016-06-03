class GobiertoSites::BudgetLinesController < GobiertoSites::ApplicationController
  before_action :load_params

  def index
    @place_budget_lines = GobiertoBudgets::BudgetLine.where(place: @place, level: @level, year: @year, kind: @kind, area_name: @area_name).all
    @sample_budget_lines = GobiertoBudgets::TopBudgetLine.limit(20).where(year: @year, place: @site.place, kind: @kind).all.sample(3)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @budget_line = GobiertoBudgets::BudgetLine.where(code: @code, place: @place, year: @year, kind: @kind, area_name: @area_name).first

    @budget_line_stats = GobiertoBudgets::BudgetLineStats.new site: @site, budget_line: @budget_line

    @budget_line_descendants = GobiertoBudgets::BudgetLine.where(place: @place, parent_code: @code, year: @year, kind: @kind, area_name: @area_name).all

    respond_to do |format|
      format.html
      format.js
    end
  end

  private

  def load_params
    @place = @site.place
    render_404 and return if @place.nil?

    @year = params[:year].to_i
    @kind = params[:kind] || GobiertoBudgets::BudgetLine::EXPENSE
    @area_name = params[:area_name] || GobiertoBudgets::BudgetLine::FUNCTIONAL
    @level = params[:level].present? ? params[:level].to_i : 1
    @code = params[:id]
  end

end
