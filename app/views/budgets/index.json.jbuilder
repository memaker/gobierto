json.records @paginated_result.records do |budget_line|
  budget_line_link = if @filter.functional?
               link_to(truncate(budget_line.name, length: 58), budget_functional_item_path(budget_line.place_id, budget_line.code, params), title: budget_line.name)
             else
               link_to(truncate(budget_line.name, length: 58), budget_economic_item_path(budget_line.place_id, budget_line.code, params), title: budget_line.name)
             end

  compare_links = <<-HTML
<div class="compare_cont">
  #{link_to 'Compara', ''}
    <div class="compare">
      #{link_to 'Con municipios de la misma CCAA', budgets_path(params.except(*reset_filters_parameters).merge({location_id: budget_line.place.province.autonomous_region.id, location_type: 'AutonomousRegion'}).symbolize_keys)}
      #{link_to 'Con municipios de la misma Provincia', budgets_path(params.except(*reset_filters_parameters).merge({location_id: budget_line.place.province.id, location_type: 'Province'}).symbolize_keys)}
      #{link_to 'Con municipios con población similar', budgets_path(params.except(*reset_filters_parameters).merge(similar_population_parameters(budget_line.population)).symbolize_keys)}
      #{link_to 'Con municipios con presupuesto similar', budgets_path(params.except(*reset_filters_parameters).merge(similar_budget_parameters(budget_line)).symbolize_keys)}
      #{link_to 'Con municipios con presupuesto total similar', budgets_path(params.except(*reset_filters_parameters).merge(total_similar_budget_parameters(budget_line.total_functional_budget)).symbolize_keys)}
    </div>
</div>
HTML

  json.evolution %Q{<span class="sparkline" data-sparkvalues='#{budget_line.historic_values.join(',')}'></span>}.html_safe
  json.name budget_line_link
  json.place_name %Q{#{link_to(truncate(budget_line.place_name, length: 28), place_path(budget_line.place, params), title: budget_line.place_name)} <span class="province">(#{budget_line.place.province.name})</span>}
  json.population budget_line.population
  json.budget_per_inhabitant budget_line.budget_per_inhabitant.to_f
  json.budget budget_line.budget
  json.percentage_from_total budget_line.percentage_from_total.to_f
  json.compare_links compare_links

end
json.queryRecordCount @paginated_result.total_records
json.totalRecordCount @paginated_result.records.length
