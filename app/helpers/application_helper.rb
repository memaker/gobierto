module ApplicationHelper
  def render_children(item, area)
    children = item.children.all.to_a

    return "" if children.empty?

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

    {format: nil, population: "#{r.first} - #{r.last}"}
  end

  def similar_budget_parameters(budget_line)
    budget = budget_line.amount
    p = 0.3
    budget_min = budget - budget*p
    budget_max = budget + budget*p

    params = {format: nil, similar_budget_min: budget_min.to_i, similar_budget_max: budget_max.to_i}
    params.merge!({functional_area: budget_line.code}) if @filter.functional?
    params.merge!({economic_area: budget_line.code}) if @filter.economic?
    params
  end

  def total_similar_budget_parameters(budget)
    p = 0.2
    budget_min = budget - budget*p
    budget_max = budget + budget*p

    {format: nil, total_similar_budget_min: budget_min.to_i, total_similar_budget_max: budget_max.to_i}
  end

  def format_currency(n)
    if n > 1_000_000
      "#{number_with_precision(n.to_f / 1_000_000.to_f, precision: 0, strip_insignificant_zeros: true)} M€"
    else
      number_to_currency(n, precision: 0, strip_insignificant_zeros: true)
    end
  end

  def delta_percentage(current_year_value, old_value)
    number_with_precision(((current_year_value.to_f - old_value.to_f)/old_value.to_f) * 100, precision: 2).to_s + " %"
  end

  def percentage_of_total(value, total)
    number_with_precision((value.to_f / total.to_f) * 100, precision: 2)
  end

  def budget_line_denomination(area, code, kind)
    area = (area == 'economic' ? EconomicArea : FunctionalArea)
    area.all_items[kind][code]
  end

  def kind_literal(kind)
    return 'ingresos' if kind == 'I'
    'gastos'
  end

  def filter_location_name
    name = ""
    if @filter.location?
      name = @filter.location.name
      if @filter.location.is_a?(INE::Places::Province)
        name += " (Provincia)"
      elsif @filter.location.is_a?(INE::Places::AutonomousRegion)
        name += " (CCAA)"
      end
    end

    name
  end

  def category_breadcrumb(category)
    (category.parents.map do |category|
      link_to(category.name, category_path(category, params))
    end + ['<h1>'+category.name+'</h1>']).join(' > ').html_safe
  end
end
