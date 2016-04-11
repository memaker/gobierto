class GobiertoParticipation::Comment < ActiveRecord::Base
  include PublicActivity::Model

  acts_as_paranoid

  scope :sorted, ->{ order(id: :asc) }

  validates :body, length: { minimum: 5 }

  belongs_to :commentable, polymorphic: true
  belongs_to :user
  belongs_to :site

  def anchor
    "comment-#{self.id}"
  end
end
