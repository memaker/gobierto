class Api::DataController < ApplicationController
  caches_page :functional, :economic

  def functional
    year = params[:year].to_i
    place = INE::Places::Place.find(params[:place_id])

    respond_to do |format|
      total = FunctionalArea.total_budget(place.id, year)
      budgets = FunctionalArea.root_items.map do |item|
        {
          name: item.name,
          value: item.budget_per_person(place, year).round(1),
          percentage: item.budget_percentage_total(place, year).round(1),
          mean_national: item.mean_national_per_person(year).round(1),
          mean_autonomy: item.mean_autonomy_per_person(year, place).round(1),
          mean_province: item.mean_province_per_person(year, place).round(1)
        }
      end

      format.json do
        render json: {
          kind: 'G',
          budgets: budgets
        }.to_json
      end
    end
  end

  def economic
    year = params[:year].to_i
    place = INE::Places::Place.find(params[:place_id])
    kind = params[:kind]

    respond_to do |format|
      total = EconomicArea.total_budget(kind,place.id, year)
      budgets = EconomicArea.root_items(kind).map do |item|
        {
          name: item.name,
          value: item.budget_per_person(place, year).round(1),
          percentage: item.budget_percentage_total(place, year).round(1),
          mean_national: item.mean_national_per_person(year).round(1),
          mean_autonomy: item.mean_autonomy_per_person(year, place).round(1),
          mean_province: item.mean_province_per_person(year, place).round(1)
        }
      end

      format.json do
        render json: {
          kind: kind,
          budgets: budgets
        }.to_json
      end
    end
  end

  def distribution
    filter = BudgetFilter.new(params.merge!({ perPage: 10000, offset: 0}))
    budget_lines = filter.apply.records

    respond_to do |format|
      format.json do
        render json: {
          kind: filter.kind,
          buckets: {
            per_person: per_person(budget_lines, :buckets),
            percentage: percentage(budget_lines, :buckets)
          },
          budgets: {
            per_person: per_person(budget_lines),
            percentage: percentage(budget_lines)
          }
        }.to_json
      end

    end
  end

  def dispersion
    filter = BudgetFilter.new(params.merge!({ perPage: 10000, offset: 0}))

    respond_to do |format|
      format.json do
        render json: dispersion_items(filter).to_json
      end
    end
  end

  private

  def per_person(budget_lines, structure = :items)
    per_inhabitant = budget_lines.sort_by{|bl| bl.budget_per_inhabitant.to_f }
    min = BigDecimal.new(per_inhabitant.first.budget_per_inhabitant)
    max = BigDecimal.new(per_inhabitant.last.budget_per_inhabitant)
    range = max - min
    width = range / 20
    mean = per_inhabitant.map { |r| BigDecimal.new(r.budget_per_inhabitant) }.reduce(:+) / per_inhabitant.size

    cuts = {}
    (min...max).step(width).each do |f|
      bucket = (f..f+width)
      cuts[bucket] = per_inhabitant.select {|bl| bucket.include?(bl.budget_per_inhabitant.to_f)}
    end

    cut_number = 0
    items = []
    cuts.each_pair do |cut,budget_lines|
      label = "de #{cut.begin.round(2).to_s}€ a #{cut.end.round(2).to_s}€"
      if (structure == :items)
        budget_lines.each do |bl|
          item = {}
          item['name'] = bl.place_name
          item['cut'] = cut_number
          item['label'] = label
          item['value'] = bl.budget_per_inhabitant.to_f.round(2)
          items << item
        end
        items << mean_item(label, cut_number, mean) if cut.include?(mean)
      else
        item = {}
        item['cut'] = cut_number
        item['label'] = label
        items << item
      end
      cut_number += 1
    end
    items
  end

  def percentage(budget_lines, structure = :items)
    
    percentage_method = derive_percentage_method(budget_lines.first)

    percentages = budget_lines.sort_by{ |bl| BigDecimal.new(bl.send(percentage_method)) }
    width = BigDecimal.new(5)
    mean = percentages.map { |r| BigDecimal.new(r.send(percentage_method)) }.reduce(:+) / percentages.size
    
    cuts = {}
    (0...100).step(width).each do |i|
      extreme = i + width
      extreme += 0.1 if extreme == 100
      bucket = (i...extreme)
      cuts[bucket] = percentages.select { |bl| bucket.include?(BigDecimal.new(bl.send(percentage_method))) }
    end

    cut_number = 0
    items = []
    cuts.each_pair do |cut, budget_lines|
      label = "de #{cut.begin.floor.round(0)}% a #{cut.end.floor.round(0)}%"
      if (structure == :items)
        budget_lines.each do |bl|
          item = {}
          item['name'] = bl.place_name
          item['cut'] = cut_number
          item['label'] = label
          item['value'] = bl.send(percentage_method).to_f.round(2)
          items << item
        end
        items << mean_item(label, cut_number, mean) if cut.include?(mean)
      else
        item = {}
        item['cut'] = cut_number
        item['label'] = label
        items << item
      end
      cut_number += 1
    end
    items
  end

  def mean_item(label, cut_number, mean)
    item = {}
    item['name'] = "mean"
    item['cut'] = cut_number
    item['label'] = label
    item['value'] = mean.round(2).to_s
    item
  end

  def derive_percentage_method(budget_line)
    return :percentage_from_total if budget_line.respond_to?(:percentage_from_total)
    return :percentage_total_functional if budget_line.respond_to?(:percentage_total_functional)
    :percentage_total_economic
  end

  def dispersion_items(filter)
    [
      {
        "name": "Murcia",
        "codigo": "1234",
        "population": 2132323,
        "total": 2323,
        "per_person": 12,
        "cut": "Menos de 10000"
      },
      {
        "codigo": 2344,
        "name": "Getafe",
        "population": 321123,
        "total": 2323,
        "per_person": 453,
        "cut": "Entre 133 y 231232"
      }
    ]

    filter.category.dispersion_items(filter.year).map do |item|
      {
        "name": item.place_name,
        "codigo": item.place_id,
        "population": item.population,
        "total": item.amount,
        "per_person": item.budget_per_inhabitant,
        "cut": item.cut
      }
    end
  end

end
