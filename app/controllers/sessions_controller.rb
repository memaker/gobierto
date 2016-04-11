class SessionsController < ApplicationController
  layout 'gobierto_budgets_application'

  before_action :logged_in_user, only: :destroy

  def new
    redirect_to root_path and return if logged_in?
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)

    if user && user.authenticate(params[:session][:password])
      log_in user
      current_user.update_pending_answers(session.id)
      track_login_user_activity
      store_subscriptions
    else
      flash.now[:alert] = 'Credenciales incorrectas. Por favor, vuelve a intentarlo'
      flash.now[:session_alert] = t('controllers.sessions.create.alert')
    end

    respond_to do |format|
      format.html do
        if logged_in?
          if user.admin?
            redirect_to admin_root_path
          else
            redirect_to :back
          end
        else
          render 'new'
        end
      end
      format.js
    end
  end

  def destroy
    if impersonated_session?
      log_out_impersonated
      redirect_to admin_users_path
    else
      log_out
      redirect_to root_path
    end
  end

  private

  def track_login_user_activity
    current_user.create_activity :login, owner: current_user, ip: remote_ip
  end
end
