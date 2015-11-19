class BudgetFilter
  def self.years
    (2010..2015).to_a.reverse
  end

  def self.populations
    [
      ['0 - 5.000',                '0 - 5000'],
      ['5.000 - 10.000',        '5000 - 10000'],
      ['10.000 - 50.000',      '10000 - 50000'],
      ['50.000 - 150.000',     '50000 - 150000'],
      ['150.000 - 500.000',   '150000 - 500000'],
      ['500.000 - 1.500.000', '500000 - 1500000'],
      ['1.500.000 - máximo', '1500000 - 100000000']
    ]
  end

  # "sorts"=>{"budget"=>"-1"}, "page"=>"1", "perPage"=>"100", "offset"=>"0"}
  def initialize(filters)
    @kind = filters[:kind]                                   if filters[:kind].present?
    @year = filters[:year].to_i                              if filters[:year].present?
    if filters[:economic_area].present?
      @economic_area_filter_code = filters[:economic_area]
      @economic_area_filter = filters[:economic_area]
    end
    if filters[:functional_area].present?
      @functional_area_filter_code = filters[:functional_area]
      @functional_area_filter = filters[:functional_area]
    end

    if filters[:population].present?
      @population_min, @population_max = filters[:population].split(' - ').map{|s| s.tr('.','').to_f }
    end
    @similar_budget_max = filters[:similar_budget_max] if filters[:similar_budget_max].present?
    @similar_budget_min = filters[:similar_budget_min] if filters[:similar_budget_min].present?
    @total_similar_budget_max = filters[:total_similar_budget_max] if filters[:total_similar_budget_max].present?
    @total_similar_budget_min = filters[:total_similar_budget_min] if filters[:total_similar_budget_min].present?

    @per_page = filters[:perPage].nil? ? 100 : filters[:perPage].to_i
    @per_page = 100 if @per_page > 100
    @offset = filters[:offset].to_i
    @sort_by = {
      attribute: (filters[:sorts].keys.first rescue 'budget'),
      direction: (filters[:sorts].values.first == '1' ? 'DESC' : 'ASC' rescue 'DESC')
    }

    @location = if filters[:location_id].present? && filters[:location_type].present?
               case filters[:location_type]
               when 'Province'
                 INE::Places::Province.find(filters[:location_id])
               when 'AutonomousRegion'
                 INE::Places::AutonomousRegion.find(filters[:location_id])
               else
                 INE::Places::Place.find(filters[:location_id])
               end
             end
  end

  attr_reader :location, :year, :kind, :per_page, :offset

  def active?
    @year.present?
  end

  def location?
    @location.present?
  end

  def functional?
    @functional_area_filter.present?
  end

  def economic?
    @functional_area_filter.blank? && @economic_area_filter.present?
  end

  def expending?
    @kind.nil? || @kind == 'G'
  end

  def income?
    @kind == 'I'
  end

  def place?
    location? && @location.is_a?(INE::Places::Place)
  end

  def apply
    # If the year is nil we assume there are no filters applied
    return PaginatedResult.new(0, []) if !active?

    if @economic_area_filter_code
      @economic_area_filter_code = nil if @economic_area_filter_code == 'all'
      EconomicArea.budgets(year: @year, location: @location, code: @economic_area_filter_code,
                           kind: @kind,
                           population: [@population_min, @population_max].compact, similar_budget: [@similar_budget_min, @similar_budget_max].compact,
                           total_similar_budget: [@total_similar_budget_min, @total_similar_budget_max].compact,
                           pagination: { per_page: @per_page, offset: @offset }, sort_by: @sort_by)
    else
      @functional_area_filter_code = nil if @functional_area_filter_code == 'all'
      FunctionalArea.budgets(year: @year, location: @location, code: @functional_area_filter_code,
                             population: [@population_min, @population_max].compact, similar_budget: [@similar_budget_min, @similar_budget_max].compact,
                             total_similar_budget: [@total_similar_budget_min, @total_similar_budget_max].compact,
                             pagination: { per_page: @per_page, offset: @offset }, sort_by: @sort_by)
    end
  end
end
