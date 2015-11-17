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
end
