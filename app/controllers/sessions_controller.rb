class SessionsController < ApplicationController
  before_action :logged_in_user, only: :destroy

  def new
    redirect_to root_path and return if logged_in?
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)

    if user && user.authenticate(params[:session][:password])
      log_in user
      redirect_to params[:back_url] || root_path
    else
      flash[:alert] = 'Credenciales incorrectas. Por favor, vuelve a intentarlo'
      redirect_to :back
    end
  end

  def destroy
    log_out
    redirect_to root_path
  end
end
