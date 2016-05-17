class Admin::GobiertoCms::PagesController < ApplicationController
  before_action :admin_user
  before_action :load_page, only: [:edit, :update, :destroy]

  def index
    @pages = @site.gobierto_cms_pages.root.sorted
    admin_add_link new_admin_gobierto_cms_page_path
  end

  def new
    @page = @site.gobierto_cms_pages.new
  end

  def create
    @page = @site.gobierto_cms_pages.new page_params
    @page.site = @site
    if @page.save
      track_create_page_activity

      redirect_to admin_gobierto_cms_pages_path, notice: t('controllers.gobierto_cms/pages.create.notice')
    else
      flash.now[:alert] = t('controllers.gobierto_cms/pages.create.alert')
      render 'new'
    end
  end

  def edit
    admin_add_link new_admin_gobierto_cms_page_path
    admin_remove_link admin_gobierto_cms_page_path(@page)
  end

  def update
    if @page.update_attributes page_params
      track_update_page_activity

      redirect_to admin_gobierto_cms_pages_path, notice: t('controllers.gobierto_cms/pages.update.notice')
    else
      flash.now[:alert] = t('controllers.gobierto_cms/pages.update.alert')
      render 'new'
    end
  end

  def batch_update
    position = 0
    params[:pages].each do |k,v|
      position +=1
      next if v[:parent_id] == "none"

      if page = @site.gobierto_cms_pages.find_by(id: v[:item_id])
        page.update_column(:position, position)
      end
    end

    render head: :success, nothing: true
  end

  def destroy
    @page.destroy
    track_destroy_page_activity

    redirect_to admin_gobierto_cms_pages_path, notice: t('controllers.gobierto_cms/pages.destroy.notice')
  end

  private

  def load_page
    @page = @site.gobierto_cms_pages.friendly.find(params[:id])
  end

  def page_params
    params.require(:gobierto_cms_page).permit(:title, :body, :parent_id, :attachments_ids)
  end

  def track_create_page_activity
    @page.create_activity :create, owner: current_user, ip: remote_ip
  end

  def track_update_page_activity
    @page.create_activity :update, owner: current_user, ip: remote_ip, parameters: { changes: @page.previous_changes.except(:updated_at) }
  end

  def track_destroy_page_activity
    @page.create_activity :destroy, owner: current_user, ip: remote_ip, parameters: { title: @page.title }
  end
end
