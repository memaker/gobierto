module PathsHelper

  def place_path(place, params)
    place_params = {location_id: place.id, location_type: 'Place', format: nil}
    place_params.merge!({functional_area: 'all', economic_area: nil}) if @filter.functional?
    place_params.merge!({functional_area: nil, economic_area: 'all'}) if @filter.economic?

    budgets_path(params.except(*reset_filters_parameters).merge(place_params).symbolize_keys)
  end

  def budget_functional_item_path(place_id, code, params)
    budgets_path(params.except(*reset_filters_parameters).merge({format: nil, location_id: place_id, location_type: 'Place', functional_area: code, economic_area: nil}).symbolize_keys)
  end

  def budget_economic_item_path(place_id, code, params)
    budgets_path(params.except(*reset_filters_parameters).merge({format: nil, location_id: place_id, location_type: 'Place', economic_area: code, functional_area: nil}).symbolize_keys)
  end

end
