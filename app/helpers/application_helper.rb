module ApplicationHelper
  def money(amount)
    number_to_currency(amount, precision: 2, separator: ',', delimiter: '.', unit: '€', format: "%n %u")
  end

  def percentage(part, total)
    result = if total > 0
               (part.to_f * 100.0)/total.to_f
             else
               0
             end
    number_to_percentage result, precision: 2
  end

  def render_children(item)
    return "" if item.children.empty?

    "<ul>
      #{item.children.map{|c| %Q{<li>#{c.name} #{render_children(c)}</li>}}.join("\n")}
    </ul>".html_safe
  end
end
