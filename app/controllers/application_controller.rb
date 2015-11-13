class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include SessionsManagement

  rescue_from ActionController::RoutingError, with: :render_404

  helper_method :current_user, :logged_in?, :current_user?, :login_path

  before_action :authenticate

  def render_404
    render file: "public/404", status: 404, layout: false, handlers: [:erb], formats: [:html]
  end

  protected

  def authenticate
    return true unless Rails.env.production?

    authenticate_or_request_with_http_basic do |username, password|
      username == 'gobierto' && password == 'presupuestos'
    end
  end

end
