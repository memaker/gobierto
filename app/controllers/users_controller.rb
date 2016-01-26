class UsersController < ApplicationController
  before_action :load_current_user, only: [:edit, :update]

  def new
    redirect_to edit_user_path if logged_in?

    @user = User.new
  end

  def create
    @user = User.find_or_initialize_by email: params[:user][:email]
    if @user.new_record?
      created = true
      @user.save!
    else
      log_in(@user)
    end

    respond_to do |format|
      format.html do
        if created
          redirect_to root_path, notice: 'Por favor, confirma tu email'
        else
          redirect_to :back
        end
      end
      format.js do
        created ? render('created') : render('logged_in')
      end
    end
  end

  def verify
    @user = User.find_by! verification_token: params[:id]
    render 'edit'
  end

  def edit
  end

  def update
    if @user.update_attributes(update_user_params)
      @user.clear_verification_token
      @user.save!
      redirect_to edit_user_path, notice: 'Datos actualizados correctamente'
    else
      flash.now.alert = 'No se han podido actualizar los datos'
      render 'edit'
    end
  end

  private

  def create_user_params
    params.require(:user).permit(:email)
  end

  def update_user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :current_password)
  end

  def load_current_user
    render_404 and return unless logged_in?

    @user = current_user
  end
end