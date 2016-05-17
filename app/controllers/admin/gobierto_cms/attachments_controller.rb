class Admin::GobiertoCms::AttachmentsController < ApplicationController
  before_action :admin_user
  before_action :load_page, except: :page

  def index
    render :json => @page.attachments.collect(&:to_jq_upload).to_json
  end

  def create
    attachment = params[:attachments].map do |attachment_params|
      GobiertoCms::Attachment.new(attachment: attachment_params).tap do |a|
        a.gobierto_cms_page_id = 0
        a.site = @site
        a.save!
      end
    end.first

    respond_to do |format|
      format.html do
        render partial: 'admin/gobierto_cms/attachments/attachment', locals: {attachment: attachment}, layout: false
      end
    end
  rescue
    render :json => [{:error => "custom_failure"}], :status => 304
  end

  def destroy
    @attachment = GobiertoCms::Attachment.find(params[:id])
    @attachment.destroy

    respond_to do |format|
      format.json { render json: true }
      format.js
    end
  end

  private

  def load_page
    @page = @site.gobierto_cms_pages.find(params[:page_id]) if params[:page_id]
  end

end
