class ApplicationController < ActionController::Base
  include SessionsManagement

  protect_from_forgery with: :exception

  rescue_from ActionController::RoutingError, with: :render_404
  rescue_from ActionController::UnknownFormat, with: :render_404

  helper_method :code_from_params, :helpers

  before_action :load_site

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
    return 'gobierto_budgets_embedded' if params[:e].present?
    return 'gobierto_budgets_application'
  end

  def default_url_options(options={})
    if params[:e].present?
      { e: true }
    else
      {}
    end
  end

  protected

  def load_site
    unless Site.reserved_domain?(domain)
      @site = Site.find_by domain: domain
    end
  end

  def store_subscriptions
    if session[:follow]
      subscription = current_user.subscriptions.create place_id: session[:follow]
      @place = subscription.place
      session[:follow] = nil
    end
  end

  def admin_add_link(path)
    @admin_add_controls = path if logged_in? && current_user.admin?
  end

  def admin_edit_link(path)
    @admin_edit_controls = path if logged_in? && current_user.admin?
  end

  def admin_remove_link(path)
    @admin_remove_controls = path if logged_in? && current_user.admin?
  end

  def remote_ip
    env['action_dispatch.remote_ip'].calculate_ip
  end

  def domain
    @domain ||= (env['HTTP_HOST'] || env['SERVER_NAME'] || env['SERVER_ADDR']).split(':').first
  end
end
