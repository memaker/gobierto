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

  def lines
    filter = BudgetFilter.new(params.merge!({ perPage: 10000, offset: 0}))

    respond_to do |format|
      format.json do
        render json: lines_items(filter).to_json
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

    items = []
    cut_number = 0
    (min...max).step(width).each do |f|
      bucket = (f..f+width)
      label = "de #{bucket.begin.round(2).to_s}€ a #{bucket.end.round(2).to_s}€"
      if (structure == :items)
        items << budget_items(per_inhabitant,bucket, :budget_per_inhabitant, label, cut_number)
        items << budget_item("mean", label, cut_number, mean) if bucket.include?(mean)
      else
        items << {'cut' => cut_number, 'label' => label}
      end
      cut_number += 1
    end
    items.flatten
  end

  def percentage(budget_lines, structure = :items)
    
    method = derive_percentage_method(budget_lines.first)

    percentages = budget_lines.sort_by{ |bl| BigDecimal.new(bl.send(method)) }
    width = BigDecimal.new(5)
    mean = percentages.map { |r| BigDecimal.new(r.send(method)) }.reduce(:+) / percentages.size
    
    items = []
    cut_number = 0
    (0...100).step(width).each do |i|
      extreme = i + width
      extreme += 0.1 if extreme == 100
      bucket = (i...extreme)
      label = "de #{bucket.begin.floor.round(0).to_s}% a #{bucket.end.floor.round(0).to_s}%"
      if (structure == :items)
        items << budget_items(percentages, bucket, method, label, cut_number)
        items << budget_item("mean", label, cut_number, mean) if bucket.include?(mean)
      else
        items << {'cut' => cut_number, 'label' => label}
      end
      cut_number += 1
    end
    items.flatten
  end

  def budget_items(lines, bucket, method, label, cut_number)
    lines.select { |bl| bucket.include?(BigDecimal.new(bl.send(method))) }.map do |bl|
      budget_item(bl.place_name, label, cut_number, bl.send(method))
    end
  end

  def budget_item(name, label, cut_number, value)
    {'name' => name,
     'cut'  => cut_number,
     'label'=> label,
     'value'=> value.to_f.round(2)}
  end

  def derive_percentage_method(budget_line)
    return :percentage_from_total if budget_line.respond_to?(:percentage_from_total)
    return :percentage_total_functional if budget_line.respond_to?(:percentage_total_functional)
    :percentage_total_economic
  end

  def dispersion_items(filter)
    filter.category.dispersion_items(filter.year).map do |item|
      {
        "name": item.place_name,
        "codigo": item.place_id,
        "population": item.population,
        "total": item.amount,
        "per_person": item.budget_per_inhabitant,
        "percentage": item.percentage,
        "cut": item.cut
      }
    end
  end

  def lines_items(filter)
    data_lines = Data::Lines.new(filter)

    return {
      "kind": filter.kind,
      "year": filter.year.to_s,
      "title": data_lines.title_name,
      "budgets":{
        "per_person":[
          {
            "name": data_lines.name,
            "values": data_lines.data_per_person
          },
          {
            "name":"mean_national",
            "values": data_lines.data_mean_national_per_person
          },
          {
            "name":"mean_autonomy",
            "values": data_lines.data_mean_autonomy_per_person
          },
          {"name":"mean_province",
           "values": data_lines.data_mean_province_per_person
          }
        ],
        "percentage":[
          {
            "name": "Porcentaje #{data_lines.name} sobre el total",
            "values": data_lines.data_percentage
          },
          {
            "name":"mean_national",
            "values": data_lines.data_mean_national_percentage
          },
          {
            "name":"mean_autonomy",
            "values": data_lines.data_mean_autonomy_percentage
          },
          {"name":"mean_province",
           "values": data_lines.data_mean_province_percentage
          }
        ]
      }
    }
  end

end
