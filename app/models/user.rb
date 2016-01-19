class User < ActiveRecord::Base
  include UserSession

  has_secure_password

  attr_accessor :terms_of_service, :remember_token, :current_password

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  validates :password, length: { minimum: 5 }, allow_blank: true
  validates :terms_of_service, acceptance: true

  before_validation :sanitize_parameters
  validate :valid_current_password

  scope :sorted, -> { order(id: :desc) }

  def full_name
    @full_name ||= [first_name, last_name].join(' ')
  end

  def pending_confirmation?
    self.verification_token.present?
  end

  def terms_of_service=(value)
    self.verification_token = nil

    @terms_of_service = value
  end

  private

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

end
