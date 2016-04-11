class GobiertoParticipation::Idea < ActiveRecord::Base
  include PublicActivity::Model

  acts_as_paranoid

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  validates :title, length: { minimum: 5 }
  validates :body, length: { minimum: 5 }

  belongs_to :user
  belongs_to :site
  has_many :comments, as: :commentable, dependent: :destroy

  scope :sorted, ->{ order(id: :desc) }

  private

  def slug_candidates
    [
      :title,
      [:title, :user_id],
      [:title, :user_id, ->{ Time.now.to_i }]
    ]
  end
end
