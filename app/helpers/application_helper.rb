module ApplicationHelper

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

  def budget_line_denomination(area, code, kind)
    area = (area == 'economic' ? EconomicArea : FunctionalArea)
    area.all_items[kind][code]
  end

  def kind_literal(kind)
    return 'ingresos' if kind == 'I'
    'gastos'
  end

  def area_literal(area)
    return 'Funcional' if area == 'functional'
    'Económica'
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
      attrs << %Q{data-track-url=#{place_path(@place.slug, @year || 2015)}}
      attrs << %Q{data-place-slug=#{@place.slug}}
      attrs << %Q{data-place-name=#{@place.name}}
    end
    attrs << %Q{data-year=#{@year || 2015}}
    attrs << %Q{data-kind=#{@kind || 'expense'}}
    attrs << %Q{data-area=#{@area_name || 'economic'}}
    attrs.join(' ')
  end
end
