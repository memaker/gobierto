class GeocoderController < ApplicationController
  def index
    result = request.location

    lat, lon = result.latitude, result.longitude
    loc1 = [lat, lon]

    dist = 500_000
    place = nil
    INE::Places::Place.all.each do |p|
      loc2 = [p.lat.to_f, p.lon.to_f]

      new_dist = distance(loc1, loc2)
      if (new_dist < dist)
        place = p
        dist = new_dist
      end
    end

    if place
      Rails.logger.info "=================================="
      Rails.logger.info place.name
      Rails.logger.info dist
      Rails.logger.info "=================================="
    end

    render nothing: true
  end

  private

  def distance(loc1, loc2)
    rad_per_deg = Math::PI/180  # PI / 180
    rkm = 6371                  # Earth radius in kilometers
    rm = rkm * 1000             # Radius in meters

    dlat_rad = (loc2[0]-loc1[0]) * rad_per_deg  # Delta, converted to rad
    dlon_rad = (loc2[1]-loc1[1]) * rad_per_deg

    lat1_rad, lon1_rad = loc1.map {|i| i * rad_per_deg }
    lat2_rad, lon2_rad = loc2.map {|i| i * rad_per_deg }

    a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
    c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))

    rm * c # Delta in meters
  end
end
