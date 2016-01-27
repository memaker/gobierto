class ApplicationController < ActionController::Base
  include SessionsManagement

  protect_from_forgery with: :exception

  rescue_from ActionController::RoutingError, with: :render_404

  helper_method :reset_filters_parameters, :code_from_params

  before_action :authenticate

  def render_404
    render file: "public/404", status: 404, layout: false, handlers: [:erb], formats: [:html]
  end

  def reset_filters_parameters
    [:location_id, :location_type, :population, :similar_budget_min, :similar_budget_max,
     :total_similar_budget_min, :total_similar_budget_max, :code, :format]
  end

  def helpers
    ActionController::Base.helpers
  end

  def code_from_params(code)
    if code.present?
      code.tr('-','.')
    end
  end

  protected

  def authenticate
    return true unless Rails.env.production?

    authenticate_or_request_with_http_basic do |username, password|
      username == 'gobierto' && password == 'presupuestos'
    end
  end

  def store_subscriptions
    if session[:follow]
      subscription = current_user.subscriptions.create place_id: session[:follow]
      @place = subscription.place
      session[:follow] = nil
    end
  end

end
