module ApplicationHelper
  def percentage(part, total)
    if total > 0
      (part.to_f * 100.0)/total.to_f
    else
      0
    end
  end

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
end
