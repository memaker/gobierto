class GobiertoSites::BudgetLinesController < GobiertoSites::ApplicationController
  before_action :load_params

  def index
    @place_budget_lines = GobiertoBudgets::BudgetLine.where(place: @place, level: @level, year: @year, kind: @kind, area_name: @area_name).all

    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @budget_line = GobiertoBudgets::BudgetLine.where(code: @code, place: @place, year: @year, kind: @kind, area_name: @area_name).first

    respond_to do |format|
      format.html
      format.js
    end
  end

  private

  def load_params
    @place = @site.place
    render_404 and return if @place.nil?

    @year = params[:year]
    @kind = params[:kind] || GobiertoBudgets::BudgetLine::EXPENSE
    @area_name = params[:area_name] || GobiertoBudgets::BudgetLine::FUNCTIONAL
    @level = params[:level].present? ? params[:level].to_i : 1
    @code = params[:id]
  end

end
