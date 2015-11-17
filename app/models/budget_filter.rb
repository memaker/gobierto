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

    @location = if filters[:location_id].present? && filters[:location_type].present?
               case filters[:location_type]
               when 'Provincia'
                 INE::Places::Province.find(filters[:location_id])
               when 'Comunidad Autónoma'
                 INE::Places::AutonomousRegion.find(filters[:location_id])
               else
                 INE::Places::Place.find(filters[:location_id])
               end
             end
  end

  attr_reader :location

  def location?
    @location.present?
  end

  def place?
    location? && @location.is_a?(INE::Places::Place)
  end

  def apply
    # If the year is nil we assume there are no filters applied
    return [] if @year.nil?

    if @economic_area_filter_code
      EconomicArea.budgets(year: @year, location: @location, code: @economic_area_filter_code, population: [@population_min, @population_max].compact)
    else
      FunctionalArea.budgets(year: @year, location: @location, code: @functional_area_filter_code, population: [@population_min, @population_max].compact)
    end
  end

  def global?
    @economic_area_filter.nil? || @functional_area_filter.nil?
  end
end
