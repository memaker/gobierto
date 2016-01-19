class UsersController < ApplicationController
  before_action :load_current_user, only: [:edit, :update]

  def new
    redirect_to edit_user_path if logged_in?

    @user = User.new
  end

  def create
    redirect_to edit_user_path if logged_in?

    @user = User.new create_user_params
    if @user.save
      log_in @user
      redirect_to params[:back_url] || root_path
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(update_user_params)
      @user.save!
      redirect_to edit_user_path, notice: 'Datos actualizados correctamente'
    else
      flash.now.alert = 'No se han podido actualizar los datos'
      render 'edit'
    end
  end

  private

  def create_user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :place_id)
  end

  def update_user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :current_password)
  end

  def load_current_user
    render_404 and return unless logged_in?

    @user = current_user
  end
end
