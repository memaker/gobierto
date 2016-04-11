class GobiertoParticipation::ConsultationOption < ActiveRecord::Base
  acts_as_paranoid

  has_many :answers, class_name: GobiertoParticipation::ConsultationAnswer, dependent: :destroy
  belongs_to :consultation
  belongs_to :site
  acts_as_list scope: :consultation

  def percentage
    count = consultation.answers.count
    if count == 0
      "0%"
    else
      "#{(consultation.answers.where(consultation_option_id: self.id).count * 100) / count }%"
    end
  end
end
