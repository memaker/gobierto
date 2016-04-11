class GobiertoParticipation::Consultation < ActiveRecord::Base
  include PublicActivity::Model

  acts_as_paranoid

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  enum kind: { open_answers: 0, closed_answers: 1 }

  validates :title, length: { minimum: 5 }
  validates :body, length: { minimum: 5 }
  validates :user_id, presence: true
  validate :options_presence

  before_validation :set_open_until
  before_save :clean_options_if_open_answers, :set_options_site

  belongs_to :site
  belongs_to :user
  has_many :options, class_name: GobiertoParticipation::ConsultationOption, dependent: :destroy
  has_many :answers, class_name: GobiertoParticipation::ConsultationAnswer, dependent: :destroy

  accepts_nested_attributes_for :options, reject_if: :all_blank, allow_destroy: true

  attr_accessor :open_until_date, :open_until_time

  scope :sorted, ->{ order(id: :desc) }

  def open?
    open_until.nil? || Time.zone.now < open_until
  end

  def closed?
    !open?
  end

  private

  def slug_candidates
    [
      :title,
      [:title, :user_id],
      [:title, :user_id, ->{ Time.now.to_i }]
    ]
  end

  def options_presence
    if closed_answers?
      if options.length < 2
        errors.add(:base, I18n.t('activerecord.errors.models.gobierto_participation_consultation.attributes.options.minimum'))
      end
    end
  end

  def clean_options_if_open_answers
    if open_answers?
      options.clear
    end
  end

  def set_options_site
    options.each do |option|
      option.site = self.site
    end
  end

  def set_open_until
    self.open_until = Time.parse(self.open_until_date + " " + self.open_until_time)
  rescue
  end
end
