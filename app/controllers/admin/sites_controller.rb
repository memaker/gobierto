class Admin::SitesController < Admin::ApplicationController

  def edit
  end

  def update
    if @site.update_attributes(site_params)
      redirect_to edit_admin_site_path, notice: t('controllers.admin/sites.update.notice')
    else
      flash[:alert] = t('controllers.admin/sites.update.alert')
      render 'edit'
    end
  end

  private

  def site_params
    params.require(:site).permit(:location_name, :institution_type, :name, :institution_url, :institution_document_number, :institution_address, :institution_email)
  end

end
