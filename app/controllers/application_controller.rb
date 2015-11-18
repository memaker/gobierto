class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  rescue_from ActionController::RoutingError, with: :render_404

  helper_method :reset_filters_parameters

  before_action :authenticate

  def render_404
    render file: "public/404", status: 404, layout: false, handlers: [:erb], formats: [:html]
  end

  def reset_filters_parameters
    [:location_id, :location_type, :population, :similar_budget_min, :similar_budget_max,
     :total_similar_budget_min, :total_similar_budget_max, :code]
  end

  protected

  def authenticate
    return true unless Rails.env.production?

    authenticate_or_request_with_http_basic do |username, password|
      username == 'gobierto' && password == 'presupuestos'
    end
  end

end
