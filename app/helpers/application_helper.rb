module ApplicationHelper

  def flush_the_flash
    output = ""

    if flash[:alert] || flash[:notice] || flash[:message]
      content_tag(:div, id: 'flash', class: "#{flash[:notice] || flash[:message] ? 'notice' : 'error'}") do
        if flash[:notice] || flash[:alert]
          output += content_tag(:p) do
            (flash[:notice] || flash[:alert]).html_safe
          end
        end

        if flash[:message]
          output += flash[:message].html_safe
        end

        output.html_safe
      end
    end
  end

  def pending(&block)
    if controller_name == 'sandbox'
      yield
    end
  end

  def format_currency(n)
    if n > 1_000_000
      "#{helpers.number_with_precision(n.to_f / 1_000_000.to_f, precision: 0, strip_insignificant_zeros: true)} M€"
    else
      helpers.number_to_currency(n, precision: 0, strip_insignificant_zeros: true)
    end
  end

  def delta_percentage(current_year_value, old_value)
    number_with_precision(((current_year_value.to_f - old_value.to_f)/old_value.to_f) * 100, precision: 2).to_s + " %"
  end

  def percentage_of_total(value, total)
    number_with_precision((value.to_f / total.to_f) * 100, precision: 2)
  end

  def area_class(area, kind)
    return FunctionalArea if (area == 'functional' && %{income i}.exclude?(kind.downcase))
    EconomicArea
  end

  def budget_line_denomination(area, code, kind, capped = -1)
    area = area_class area, kind
    if area.all_items[kind][code].nil?
      res = " - "
    else
      res = area.all_items[kind][code][0..capped]
      res += "..." if capped > -1
    end
    res
  end

  def budget_line_description(area, code, kind)
    area = area_class area, kind
    area.all_descriptions[kind][code.to_s]
  end

  def kind_literal(kind, plural = true)
    if kind == 'I'
      plural ? 'ingresos' : 'ingreso'
    else
      plural ? 'gastos' : 'gasto'
    end
  end

  def area_literal(area)
    area == 'functional' ? 'Funcional' : 'Económica'
  end

  def other_kind(kind)
    kind == 'I' ? 'G' : 'I'
  end

  def budget_line_crumbs(budget_line, type)
    crumbs = [budget_line]
    parent_code = budget_line['parent_code']

    while parent_code.present? do
      p = BudgetLine.find(ine_code: budget_line['ine_code'], code: parent_code, year: budget_line['year'], kind: budget_line['kind'], type: type)
      crumbs.unshift(p)
      parent_code = p['parent_code']
    end

    return crumbs
  end

  def link_to_place_budget_toggler(slug, area, selectedArea, year)
    buttonSelected = " buttonSelected" if area == selectedArea
    link_to area_literal(area), place_budget_path(slug, year, 'expense', {area: area}), class: "toggle #{buttonSelected}"
  end

  def link_to_parent_comparison(places, year, kind, area_name, parent_code)
    options = {}
    options[:parent_code] = parent_code[0..-2] if parent_code.length > 1
    link_to('« anterior', places_compare_path(places.map(&:slug).join(':'),year,kind,area_name, options))
  end

  def lines_chart_api_path(what, compared_level, places, year, kind, parent_code = nil, area_name = 'economic')
    place_ids = places.map(&:id).join(':')
    path = if compared_level > 1
      api_data_compare_budget_lines_path(place_ids, year, what, kind, parent_code, area_name, format: :json )
    else
      api_data_compare_path(place_ids, year, what, kind: kind, format: :json)
    end
    path
  end

  def items_in_level(budget_lines, level, parent_code)
    budget_lines.select {|bl| bl['level'] == level && bl['parent_code'] == parent_code }.uniq{|bl| bl['code'] }
  end

  def categories_in_level(area, kind, level, parent_code)
    area = area_class area, kind
    area.all_items[kind].select{|k,v| k.length == level && k.starts_with?(parent_code.to_s)}.sort_by{|k,v| k}
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

  def data_attributes
    attrs = []
    if @place
      attrs << %Q{data-track-url="#{place_path(@place.slug, @year || 2015)}"}
      attrs << %Q{data-place-slug="#{@place.slug}"}
      attrs << %Q{data-place-name="#{@place.name}"}
    end
    if action_name == 'compare' and controller_name == 'places'
      attrs << %Q{data-comparison-name="#{@places.map{|p| p.name }.join(' + ')}"}
      attrs << %Q{data-comparison-track-url="#{request.path}"}
      attrs << %Q{data-comparison-slug="#{params[:slug_list]}"}
    end
    attrs << %Q{data-year="#{@year || 2015}"}
    attrs << %Q{data-kind="#{@kind || 'expense'}"}
    attrs << %Q{data-area="#{@area_name || 'economic'}"}
    attrs.join(' ').html_safe
  end

  def ranking_variable(what)
    if what == 'amount_per_inhabitant'
      @code.present? ? what : 'total_budget_per_inhabitant'
    elsif what == 'amount'
      @code.present? ? what : 'total_budget'
    elsif what == 'population'
      'value'
    end
  end

  def compare_slug(place, year)
    "#{place.name}|#{place_path(place, year)}|#{place.slug}"
  end

  def places_for_select
    INE::Places::Place.all.map do |place|
      [place.name, place.id]
    end
  end

  def aarr_for_select
    INE::Places::AutonomousRegion.all.sort_by(&:name).map do |ar|
      [ar.name, ar.id]
    end
  end

  def parent_code(code)
    if code.present?
      if code.include?('-')
        code.split('-').first
      else
        code[0..-2]
      end
    end
  end

  def twitter_share(message, url)
    short_url_length = 24
    total_message_length = 140
    signature = "En @gobierto: "
    max_message_length = total_message_length - short_url_length - signature.length

    to_share = signature
    to_share += (message.length > max_message_length) ? message.slice(0, max_message_length - 3) + "..." : message
    to_share += " "+url
    to_share
  end

  def answers_path_with_params(question_id, answer_text)
    answers_path(answer: {
      question_id: question_id, answer_text: answer_text,
      place_id: @place.id, year: @year, kind: @kind, area_name: @area_name, code: @code
    })
  end

  def markdown(text)
    return if text.blank?

    options = {
      filter_html:     true,
      hard_wrap:       true, 
      link_attributes: { rel: 'nofollow', target: "_blank" },
      space_after_headers: true, 
      fenced_code_blocks: true
    }

    extensions = {
      autolink:           true,
      superscript:        true,
      disable_indented_code_blocks: true
    }

    renderer = Redcarpet::Render::HTML.new(options)
    markdown = Redcarpet::Markdown.new(renderer, extensions)

    markdown.render(text).html_safe
  end

end
