class SessionsController < ApplicationController
  before_action :logged_in_user, only: :destroy

  def new
    redirect_to root_path and return if logged_in?
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)

    if user && user.authenticate(params[:session][:password])
      log_in user
      user.update_pending_answers(session.id)
    else
      flash[:alert] = 'Credenciales incorrectas. Por favor, vuelve a intentarlo'
    end

    respond_to do |format|
      format.html do
        if logged_in?
          redirect_to :back
        else
          render 'new'
        end
      end
      format.js
    end
  end

  def destroy
    log_out
    redirect_to root_path
  end
end
