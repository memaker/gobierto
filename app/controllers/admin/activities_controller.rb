class Admin::ActivitiesController < Admin::ApplicationController

  def index
    @activities = Activity.fetch_all_activity.page params[:page]
  end

end
