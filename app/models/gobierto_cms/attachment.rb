class GobiertoCms::Attachment < ActiveRecord::Base

  belongs_to :page, class_name: GobiertoCms::Page, foreign_key: :gobierto_cms_page_id
  belongs_to :site

  attr_accessor :attachment
  has_attached_file :attachment, :path => (Rails.env.production? ? ":tenant/:class/:attachment/:basename.:extension" : "public/system/:tenant/:class/:attachment/:basename.:extension")

  do_not_validate_attachment_file_type :attachment

  include Rails.application.routes.url_helpers

  def to_jq_upload
    {
      name: attachment_file_name,
      size: attachment_file_size,
      url: attachment.url(:original),
      delete_url: admin_gobierto_cms_attachment(self),
      delete_type: "DELETE"
    }
  end

  def page_nil?
    self.gobierto_cms_page_id == 0
  end
end
