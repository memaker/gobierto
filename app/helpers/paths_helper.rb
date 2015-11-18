module PathsHelper

  def place_path(place, params)
    budgets_path(params.except(*reset_filters_parameters).merge({location_id: place.id, location_type: 'Place', functional_area: nil}).symbolize_keys)
  end

  def budget_functional_item_path(place_id, code, params)
    budgets_path(params.except(*reset_filters_parameters).merge({location_id: place_id, location_type: 'Place', functional_area: code}).symbolize_keys)
  end

end
