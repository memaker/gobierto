class BudgetLine < OpenStruct
  def amount
    super.to_f
  end

  def population
    @population ||= Population.by_place_id(place_id)
  end

  def place
    @place ||= INE::Places::Place.find(place_id)
  end
end
