class BudgetFilter
  def self.years
    (2010..2015).to_a.reverse
  end

  def self.populations
    [
      ['0 - 5.000',           5_000],
      ['5.000 - 10.000',      10_000],
      ['10.000 - 50.000',     50_000],
      ['50.000 - 150.000',    150_000],
      ['150.000 - 500.000',   500_000],
      ['500.000 - 1.500.000', 1_500_000],
      ['1.500.000 - máximo',  99_999_999]
    ]
  end

  def initialize(filters)
    @year = filters[:year].to_i                              if filters[:year].present?
    @economic_area_filter_code = filters[:economic_area]     if filters[:economic_area].present?
    @functional_area_filter_code = filters[:functional_area] if filters[:functional_area].present?

    @place = if filters[:place].present?
               INE::Places::Place.find(filters[:place])
             end
  end

  attr_reader :place

  def place?
    @place.present?
  end

  def apply
    # If the year is nil we assume there are no filters applied
    return [] if @year.nil?

    if @economic_area_filter_code
      EconomicArea.budgets(year: @year, place: @place, code: @economic_area_filter_code)
    else
      FunctionalArea.budgets(year: @year, place: @place, code: @functional_area_filter_code)
    end
  end

  def global?
    @economic_area_filter.nil? || @functional_area_filter.nil?
  end
end
