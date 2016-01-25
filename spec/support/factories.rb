module Factories
  def create_user(attrs = {})
    attrs[:email]     ||= "foo@example.com"
    attrs[:password]  ||= "foo123456"
    attrs[:password_confirmation] ||= attrs[:password]
    User.new(attrs).tap do |u|
      u.save!
      u.clear_verification_token
      u.save!
    end
  end
end
