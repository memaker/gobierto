class Admin::UsersController < Admin::ApplicationController
  before_action :load_user, only: [:restore, :impersonate, :edit, :update, :destroy]

  def index
    @users = User.with_deleted.sorted
  end

  def impersonate
    store_admin_session
    log_in @user
    track_impersonate_user_activity
    redirect_to gobierto_participation_root_path
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      track_update_user_activity

      redirect_to edit_admin_user_path(@user), notice: t('controllers.admin/users.update.notice')
    else
      flash[:alert] = t('controllers.admin/users.update.alert')
      render 'edit'
    end
  end

  def destroy
    @user.destroy
    track_destroy_user_activity
    redirect_to admin_users_path, notice: t('controllers.admin/users.destroy.notice')
  end

  def restore
    @user.restore(recursive: true)
    track_restore_user_activity
    redirect_to admin_users_path, notice: t('controllers.admin/users.restore.notice')
  end

  private

  def load_user
    @user = User.with_deleted.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :document_number)
  end

  def track_impersonate_user_activity
    @user.create_activity :impersonate, owner: current_user, ip: remote_ip
  end

  def track_update_user_activity
    @user.create_activity :update, owner: current_user, ip: remote_ip, parameters: { changes: @user.previous_changes.except(:updated_at, :password_confirmation, :password) }
  end

  def track_destroy_user_activity
    @user.create_activity :destroy, owner: current_user, ip: remote_ip, parameters: { full_name: @user.full_name }
  end

  def track_restore_user_activity
    @user.create_activity :restore, owner: current_user, ip: remote_ip
  end

end
