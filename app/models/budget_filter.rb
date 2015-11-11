class BudgetFilter
  def filter(filters)
    year = filters[:year].to_i
    place = INE::Places::Place.find(filters[:place])

    if filters[:economic_area].present?
      EconomicArea.budgets(year: year, place: place, code: filters[:economic_area])
    elsif filters[:functional_area].present?
      FunctionalArea.budgets(year: year, place: place, code: filters[:functional_area])
    end
  end
end
