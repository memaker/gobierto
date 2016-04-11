class GobiertoParticipation::ConsultationAnswer < ActiveRecord::Base
  include PublicActivity::Model

  acts_as_paranoid

  scope :sorted, ->{ order(id: :asc) }

  validate :required_attributes_for_consultation

  belongs_to :consultation, class_name: GobiertoParticipation::Consultation
  belongs_to :user
  belongs_to :option, class_name: GobiertoParticipation::ConsultationOption, foreign_key: :consultation_option_id
  belongs_to :site

  def anchor
    "answer-#{self.id}"
  end

  private

  def required_attributes_for_consultation
    if self.consultation and self.consultation.closed?
      errors.add(:consultation, I18n.t('activerecord.errors.models.gobierto_participation_consultation_answer.attributes.consultation.closed'))
    end

    if consultation.open_answers?
      required_attributes_for_open_answers_consultation
    else
      required_attributes_for_closed_answers_consultation
    end
  end

  def required_attributes_for_open_answers_consultation
    minimum = 5

    if self.answer and self.answer.length <= minimum
      errors.add(:answer, I18n.t('errors.messages.too_short', count: minimum))
    end
  end

  def required_attributes_for_closed_answers_consultation
    if self.answer.present?
      errors.add(:answer, I18n.t('errors.messages.present'))
    end

    if self.option.nil?
      errors.add(:option, I18n.t('errors.messages.present'))
    end
  end

end
