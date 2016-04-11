module Factories
  def create_user(attrs = {})
    attrs[:email]     ||= "foo@example.com"
    attrs[:password]  ||= "foo123456"
    attrs[:password_confirmation] ||= attrs[:password]
    attrs[:place_id] ||= 28079
    attrs[:terms_of_service] ||= true
    GobiertoBudgets::User.new(attrs).tap do |u|
      u.save!
      u.clear_verification_token
      u.save!
    end
  end
end
