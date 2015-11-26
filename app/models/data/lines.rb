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
    population = Population.find @filter.location.id
    if @filter.category_filter?
      category_budget = if @filter.functional?
        FunctionalYearlyTotal.where(ine_code: @filter.location.id, cdfgr: @filter.category.code).first
      else
        EconomicYearlyTotal.where(ine_code: @filter.location.id, cdcta: @filter.category.code, kind: @filter.kind).first
      end
      column_name = "total_%d"
      BudgetFilter.years.map do |year|
        {
          date: year.to_s,
          value: category_budget.send(column_name % year) / population.total
        }
      end
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
          value: population.send(column_name % year) / population.total
        }
      end
    end
  end

  def data_mean_national_per_person
    if @filter.category_filter?
      category_budget = if @filter.functional?
        FunctionalYearlyTotal.where(cdfgr: @filter.category.code)
      else
        EconomicYearlyTotal.where(cdcta: @filter.category.code, kind: @filter.kind)
      end
      column_name = "total_%d"
      BudgetFilter.years.map do |year|
        {
          date: year.to_s,
          value: (category_budget.sum(column_name % year) / Population.sum('total')).to_f
        }
      end
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
    population_scoped = Population.where(autonomous_region_id: @filter.location.province.autonomous_region.id)
    if @filter.category_filter?
      category_budget = if @filter.functional?
        FunctionalYearlyTotal.where(cdfgr: @filter.category.code)
      else
        EconomicYearlyTotal.where(cdcta: @filter.category.code, kind: @filter.kind)
      end
      category_budget = category_budget.joins("INNER JOIN poblacion_municipal_2014 ON poblacion_municipal_2014.codigo = #{category_budget.table_name}.ine_code AND poblacion_municipal_2014.autonomous_region_id = #{@filter.location.province.autonomous_region.id}")
      column_name = "total_%d"
      BudgetFilter.years.map do |year|
        {
          date: year.to_s,
          value: (category_budget.sum(column_name % year) / population_scoped.sum('total')).to_f
        }
      end
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
          value: population_scoped.sum(column_name % year) / population_scoped.sum('total')
        }
      end
    end
  end

  def data_mean_province_per_person
    population_scoped = Population.where(province_id: @filter.location.province.id)
    if @filter.category_filter?
      category_budget = if @filter.functional?
        FunctionalYearlyTotal.where(cdfgr: @filter.category.code)
      else
        EconomicYearlyTotal.where(cdcta: @filter.category.code, kind: @filter.kind)
      end
      category_budget = category_budget.joins("INNER JOIN poblacion_municipal_2014 ON poblacion_municipal_2014.codigo = #{category_budget.table_name}.ine_code AND poblacion_municipal_2014.province_id = #{@filter.location.province.id}")
      column_name = "total_%d"
      BudgetFilter.years.map do |year|
        {
          date: year.to_s,
          value: (category_budget.sum(column_name % year) / population_scoped.sum('total')).to_f
        }
      end
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
          value: population_scoped.sum(column_name % year) / population_scoped.sum('total')
        }
      end
    end
  end



  def data_percentage
    population = Population.find @filter.location.id
    if @filter.category_filter?
      total_column_name = if @filter.functional?
                      "total_functional_%d"
                    elsif @filter.expending?
                      "total_economic_%d_expending"
                    else
                      "total_economic_%d_incoming"
                    end
      category_budget = if @filter.functional?
        FunctionalYearlyTotal.where(cdfgr: @filter.category.code, ine_code: @filter.location.id).first
      else
        EconomicYearlyTotal.where(cdcta: @filter.category.code, kind: @filter.kind, ine_code: @filter.location.id).first
      end
      column_name = "total_%d"
      BudgetFilter.years.map do |year|
        {
          date: year.to_s,
          value: percentage(category_budget.send(column_name % year), population.send(total_column_name % year))
        }
      end
    else
      return []
    end
  end

  def data_mean_national_percentage
    if @filter.category_filter?
      category_budget = if @filter.functional?
        FunctionalYearlyTotal.where(cdfgr: @filter.category.code)
      else
        EconomicYearlyTotal.where(cdcta: @filter.category.code, kind: @filter.kind)
      end
      column_name = "total_%d"
      BudgetFilter.years.map do |year|
        {
          date: year.to_s,
          value: percentage(category_budget.where(ine_code: @filter.location.id).first.send(column_name % year), category_budget.sum(column_name % year))
        }
      end
    else
      return []
    end
  end

  def data_mean_autonomy_percentage
    population = Population.find @filter.location.id
    population_scoped = Population.where(autonomous_region_id: @filter.location.province.autonomous_region.id)

    if @filter.category_filter?
      category_budget = if @filter.functional?
        FunctionalYearlyTotal.where(cdfgr: @filter.category.code)
      else
        EconomicYearlyTotal.where(cdcta: @filter.category.code, kind: @filter.kind)
      end
      category_budget_scoped = category_budget.joins("INNER JOIN poblacion_municipal_2014 ON poblacion_municipal_2014.codigo = #{category_budget.table_name}.ine_code AND poblacion_municipal_2014.autonomous_region_id = #{@filter.location.province.autonomous_region.id}")
      column_name = "total_%d"
      BudgetFilter.years.map do |year|
        {
          date: year.to_s,
          value: percentage(category_budget.where(ine_code: @filter.location.id).first.send(column_name % year), category_budget_scoped.sum(column_name % year))
        }
      end
    else
      return []
    end
  end

  def data_mean_province_percentage
    population = Population.find @filter.location.id
    population_scoped = Population.where(province_id: @filter.location.province.id)

    if @filter.category_filter?
      category_budget = if @filter.functional?
        FunctionalYearlyTotal.where(cdfgr: @filter.category.code)
      else
        EconomicYearlyTotal.where(cdcta: @filter.category.code, kind: @filter.kind)
      end
      category_budget_scoped = category_budget.joins("INNER JOIN poblacion_municipal_2014 ON poblacion_municipal_2014.codigo = #{category_budget.table_name}.ine_code AND poblacion_municipal_2014.province_id = #{@filter.location.province.id}")
      column_name = "total_%d"
      BudgetFilter.years.map do |year|
        {
          date: year.to_s,
          value: percentage(category_budget.where(ine_code: @filter.location.id).first.send(column_name % year), category_budget_scoped.sum(column_name % year))
        }
      end
    else
      return []
    end
  end

  private

  def totals_klass
    @filter.functional? ? FunctionalYearlyTotal : EconomicYearlyTotal
  end

  def percentage(v1,v2)
    return v1.to_f/v2.to_f
  end

end
