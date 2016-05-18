class GobiertoSites::BudgetsController < GobiertoSites::ApplicationController
  before_action :load_place, :load_year

  def index
  end

  private

  def load_place
    @place = @site.place
    render_404 and return if @place.nil?
  end

  def load_year
    if params[:year].nil?
      redirect_to gobierto_sites_budgets_path(Date.today.year - 1) and return false
    else
      @year = params[:year]
    end
  end

end
