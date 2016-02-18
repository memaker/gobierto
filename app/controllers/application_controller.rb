class ApplicationController < ActionController::Base
  include SessionsManagement

  protect_from_forgery with: :exception

  rescue_from ActionController::RoutingError, with: :render_404
  rescue_from ActionController::UnknownFormat, with: :render_404

  helper_method :code_from_params

  def render_404
    render file: "public/404", status: 404, layout: false, handlers: [:erb], formats: [:html]
  end

  def helpers
    ActionController::Base.helpers
  end

  def code_from_params(code)
    if code.present?
      code.tr('-','.')
    end
  end

  def choose_layout
    response.headers.delete "X-Frame-Options"
    # response.headers["X-FRAME-OPTIONS"] = "ALLOW-FROM http://some-origin.com"
    return 'embedded' if params[:e].present?
    return 'application'
  end

  def default_url_options(options={})
    if params[:e].present?
      { e: true }
    else
      {}
    end
  end

  protected

  def store_subscriptions
    if session[:follow]
      subscription = current_user.subscriptions.create place_id: session[:follow]
      @place = subscription.place
      session[:follow] = nil
    end
  end

end
