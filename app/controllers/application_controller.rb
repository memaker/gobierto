class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include SessionsManagement

  rescue_from ActionController::RoutingError, with: :render_404

  before_action :set_locale
  helper_method :current_user, :logged_in?, :current_user?, :login_path

  def render_404
    render file: "public/404", status: 404, layout: false, handlers: [:erb], formats: [:html]
  end

end
