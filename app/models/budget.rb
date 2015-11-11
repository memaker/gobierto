class Budget < OpenStruct
  def self.years
    (2010..2015).to_a.reverse
  end

  def amount
    super.to_f
  end

  def population
    @population ||= Population.by_place_id(place_id)
  end
end
