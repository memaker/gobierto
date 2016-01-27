class Subscription < ActiveRecord::Base
  belongs_to :user

  def self.for_place(place)
    Subscription.where(place_id: place.id).count
  end

  def place
    INE::Places::Place.find place_id
  end
end
