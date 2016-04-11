# Activity model for customisation & custom methods
class Activity < PublicActivity::Activity
  paginates_per 20

  PUBLIC_KEYS = %w(
    gobierto_participation_idea.create
    gobierto_participation_comment.create
    gobierto_participation_consultation.create
    gobierto_participation_consultation.closed
  )

  scope :sorted, -> { order(id: :desc) }

  def self.fetch_public_activity
    limit(10).sorted.where(key: PUBLIC_KEYS)
  end

  def self.fetch_all_activity
    limit(10).sorted
  end

end
