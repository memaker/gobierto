class Data::Lines
  def initialize(filter)
    @filter = filter
  end

  def name
    if @filter.category_filter?
      @filter.category.name
    else
      @filter.location.name
    end
  end

  def data_per_person
    if @filter.category_filter?
    else
      population = Population.find @filter.location.id
      column_name = if @filter.functional?
                      "total_functional_%d"
                    elsif @filter.expending?
                      "total_economic_%d_expending"
                    else
                      "total_economic_%d_incoming"
                    end
      BudgetFilter.years.map do |year|
        {
          date: year.to_s,
          value: population.send(column_name % year) / population.total
        }
      end
    end
  end

  def data_mean_national_per_person
    if @filter.category_filter?
    else
      column_name = if @filter.functional?
                      "total_functional_%d"
                    elsif @filter.expending?
                      "total_economic_%d_expending"
                    else
                      "total_economic_%d_incoming"
                    end
      BudgetFilter.years.map do |year|
        {
          date: year.to_s,
          value: Population.sum(column_name % year) / Population.sum('total')
        }
      end
    end
  end

  def data_mean_autonomy_per_person
    if @filter.category_filter?
    else
      population_scoped = Population.where(autonomous_region_id: @filter.location.province.autonomous_region.id)
      column_name = if @filter.functional?
                      "total_functional_%d"
                    elsif @filter.expending?
                      "total_economic_%d_expending"
                    else
                      "total_economic_%d_incoming"
                    end
      BudgetFilter.years.map do |year|
        {
          date: year.to_s,
          value: population_scoped.sum(column_name % year) / population_scoped.sum('total')
        }
      end
    end
  end

  def data_mean_province_per_person
    if @filter.category_filter?
    else
      population_scoped = Population.where(province_id: @filter.location.province.id)
      column_name = if @filter.functional?
                      "total_functional_%d"
                    elsif @filter.expending?
                      "total_economic_%d_expending"
                    else
                      "total_economic_%d_incoming"
                    end
      BudgetFilter.years.map do |year|
        {
          date: year.to_s,
          value: population_scoped.sum(column_name % year) / population_scoped.sum('total')
        }
      end
    end
  end

  def data_percentage
    if @filter.category_filter?
    else
      population = Population.find @filter.location.id
      column_name = if @filter.functional?
                      "total_functional_%d"
                    elsif @filter.expending?
                      "total_economic_%d_expending"
                    else
                      "total_economic_%d_incoming"
                    end
      BudgetFilter.years.map do |year|
        {
          date: year.to_s,
          value: (population.send(column_name % year)) / Population.sum(column_name % year)
        }
      end
    end
  end

  def data_mean_national_percentage
    if @filter.category_filter?
    else
      population = Population.find @filter.location.id
      column_name = if @filter.functional?
                      "total_functional_%d"
                    elsif @filter.expending?
                      "total_economic_%d_expending"
                    else
                      "total_economic_%d_incoming"
                    end
      BudgetFilter.years.map do |year|
        {
          date: year.to_s,
          value: (population.send(column_name % year)) / Population.sum(column_name % year)
        }
      end
    end
  end

  def data_mean_autonomy_percentage
    if @filter.category_filter?
    else
      population = Population.find @filter.location.id
      population_scoped = Population.where(autonomous_region_id: @filter.location.province.autonomous_region.id)
      column_name = if @filter.functional?
                      "total_functional_%d"
                    elsif @filter.expending?
                      "total_economic_%d_expending"
                    else
                      "total_economic_%d_incoming"
                    end
      BudgetFilter.years.map do |year|
        {
          date: year.to_s,
          value: (population.send(column_name % year)) / population_scoped.sum(column_name % year)
        }
      end
    end
  end

  def data_mean_province_percentage
    if @filter.category_filter?
    else
      population = Population.find @filter.location.id
      population_scoped = Population.where(province_id: @filter.location.province.id)
      column_name = if @filter.functional?
                      "total_functional_%d"
                    elsif @filter.expending?
                      "total_economic_%d_expending"
                    else
                      "total_economic_%d_incoming"
                    end
      BudgetFilter.years.map do |year|
        {
          date: year.to_s,
          value: (population.send(column_name % year)) / population_scoped.sum(column_name % year)
        }
      end
    end
  end

end
