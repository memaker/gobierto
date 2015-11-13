class BudgetFilter
  def self.years
    (2010..2015).to_a.reverse
  end

  def self.populations
    [
      ['0 - 5.000'],
      ['5.000 - 10.000'],
      ['10.000 - 50.000'],
      ['50.000 - 150.000'],
      ['150.000 - 500.000'],
      ['500.000 - 1.500.000'],
      ['1.500.000 - máximo']
    ]
  end

  def initialize(filters)
    @year = filters[:year].to_i                              if filters[:year].present?
    @economic_area_filter_code = filters[:economic_area]     if filters[:economic_area].present?
    @functional_area_filter_code = filters[:functional_area] if filters[:functional_area].present?
    if filters[:population].present?
      @population_min, @population_max = filters[:population].split(' - ').map{|s| s.tr('.','').to_f }
    end

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
      EconomicArea.budgets(year: @year, place: @place, code: @economic_area_filter_code, population: [@population_min, @population_max].compact)
    else
      FunctionalArea.budgets(year: @year, place: @place, code: @functional_area_filter_code, population: [@population_min, @population_max].compact)
    end
  end

  def global?
    @economic_area_filter.nil? || @functional_area_filter.nil?
  end
end
