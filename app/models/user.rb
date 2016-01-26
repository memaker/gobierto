class User < ActiveRecord::Base
  include UserSession

  has_secure_password validations: false

  attr_accessor :terms_of_service, :remember_token, :current_password

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  validates :first_name, length: { maximum: 50 }
  validates :last_name, length: { maximum: 50 }
  validates :password, length: { minimum: 5 }, presence: true, on: :update
  validates :terms_of_service, acceptance: true

  before_validation :sanitize_parameters, :set_verification_token
  after_create :send_verification_email
  validate :valid_current_password

  scope :sorted, -> { order(id: :desc) }

  def full_name
    @full_name ||= [first_name, last_name].compact.join(' ')
  end

  def pending_confirmation?
    self.verification_token.present?
  end

  def clear_verification_token
    self.verification_token = nil
  end

  def update_pending_answers(session_id)
    Answer.where({temporary_user_id: session_id}).update_all({user_id: self.id, temporary_user_id: nil})
  end

  def has_replied?(options)
    Answer.where(options.merge(user_id: self.id)).first
  end

  private

  def set_verification_token
    self.verification_token = generate_token
  end

  def sanitize_parameters
    self.email = self.email.downcase.strip if self.email.present?
    self.first_name = self.first_name.strip if self.first_name.present?
    self.last_name = self.last_name.strip if self.last_name.present?
  end

  def valid_current_password
    return true if self.new_record? || self.password_digest_was.blank? || self.password_reset_token.present?

    if self.password_digest_changed?
      unless User.find(self.id).authenticate(self.current_password)
        errors.add(:base, 'Contraseña actual no es válida')
        return false
      end
    end
    return true
  end

  def send_verification_email
    UserMailer.verification_notification(self).deliver_now
  end

end
