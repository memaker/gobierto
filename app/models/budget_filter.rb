class BudgetFilter
  def self.years
    (2010..2015).to_a.reverse
  end

  def self.populations
    [
      ['0 - 5.000', 5_000],
      ['5.000 - 10.000', 10_000],
      ['10.000 - 50.000', 50_000],
      ['50.000 - 150.000', 150_000],
      ['150.000 - 500.000', 500_000],
      ['500.000 - 1.500.000', 1_500_000],
      ['1.500.000 - máximo', 99_999_999]
    ]
  end

  def initialize(filters)
    @year = filters[:year].to_i
    @place = INE::Places::Place.find(filters[:place])
    @place.total_budget = FunctionalArea.total_budget(@place, @year)
    @economic_area_filter = filters[:economic_area]
    @functional_area_filter = filters[:functional_area]
  end

  def apply
    if @economic_area_filter.present?
      EconomicArea.budgets(year: @year, place: @place, code: @economic_area_filter)
    else
      FunctionalArea.budgets(year: @year, place: @place, code: @functional_area_filter)
    end
  end

  def global?
    @economic_area_filter.blank? || @functional_area_filter.blank?
  end
end
