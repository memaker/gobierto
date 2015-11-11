class BudgetFilter
  def initialize(filters)
    @year = filters[:year].to_i
    @place = INE::Places::Place.find(filters[:place])
    @economic_area_filter = filters[:economic_area]
    @functional_area_filter = filters[:functional_area]
  end

  def filter
    if @economic_area_filter.present?
      EconomicArea.budgets(year: @year, place: @place, code: @economic_area_filter)
    else
      FunctionalArea.budgets(year: @year, place: @place, code: @functional_area_filter)
    end
  end

  def by_place?
    @economic_area_filter.blank? || @functional_area_filter.blank?
  end
end
