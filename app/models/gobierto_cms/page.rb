class GobiertoCms::Page < ActiveRecord::Base
  include PublicActivity::Model
  extend ActsAsTree::TreeWalker

  acts_as_paranoid

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  validates :title, presence: true
  validates :body, presence: true

  acts_as_tree order: 'position'
  acts_as_list scope: :parent_id

  belongs_to :site
  has_many :attachments, class_name: GobiertoCms::Attachment, foreign_key: :gobierto_cms_page_id

  attr_accessor :attachments_ids

  after_save :update_attachments

  def self.root
    where(parent_id: nil)
  end

  scope :sorted, -> { order(position: :asc) }

  def parents
    @parents ||= begin
      page = self
      parents = []
      while page.parent_id?
        page = page.parent
        parents << page
      end
      parents
    end
  end

  private

  def slug_candidates
    [
      :title,
      [:title, ->{ Time.now.to_i }]
    ]
  end

  def update_attachments
    if self.attachments_ids.present?
      GobiertoCms::Attachment.where(id: temporary_attachments_ids).each do |a|
        a.page = self
        a.save!
      end
    end
  end

  def temporary_attachments_ids
    self.attachments_ids.split(',').map(&:to_i).delete_if{ |e| e == 0 }
  end
end
