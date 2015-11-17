module ApplicationHelper
  def render_children(item, area)
    return "" if item.children.empty?

    "<ul>
      #{item.children.map do |c|
        %Q{<li>
        #{link_to(c.name, '#', data: { 'menu-area' => c.code, 'rel' => area })}
        #{render_children(c, area)}</li>}
      end.join("\n")}
    </ul>".html_safe
  end

  def similar_population_parameters(population)
    r = BudgetFilter.populations.map do |filter|
      array = filter.first.split(' - ').map{|s| s.tr('.','').to_i }
      array[1] = 100_000_000 if array[1] == 0
      Range.new *array
    end.detect{|r| r.include?(population) }

    {population: "#{r.first} - #{r.last}"}
  end

  def similar_budget_parameters(budget_line)
    budget = budget_line.amount
    p = 0.3
    budget_min = budget - budget*p
    budget_max = budget + budget*p

    {similar_budget_min: budget_min.to_i, similar_budget_max: budget_max.to_i, functional_area: budget_line.code}
  end

  def total_similar_budget_parameters(budget)
    p = 0.2
    budget_min = budget - budget*p
    budget_max = budget + budget*p

    {total_similar_budget_min: budget_min.to_i, total_similar_budget_max: budget_max.to_i}
  end

  def format_currency(n)
    if n > 1_000_000
      "#{number_with_precision(n.to_f / 1_000_000.to_f, precision: 0, strip_insignificant_zeros: true)} M€"
    else
      number_to_currency(n, precision: 0, strip_insignificant_zeros: true)
    end
  end

  def percentage(current_year_value, old_value)
    number_with_precision(((current_year_value.to_f - old_value.to_f)/old_value.to_f) * 100, precision: 2).to_s + " %"
  end

  def place_path(place, params)
    budgets_path(params.except(*reset_filters_parameters).merge({location_id: place.id, location_type: 'Place'}).symbolize_keys)
  end

end
