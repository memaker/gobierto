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
          percentage: item.budget_percentage_total(place, year, total).round(1),
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
          percentage: item.budget_percentage_total(place, year, total).round(1),
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
    filter = BudgetFilter.new(params)
    budget_lines = filter.apply

    respond_to do |format|
      format.json do
        render json: {
          kind: filter.kind,
          budgets: {
            per_person: per_person_items(budget_lines),
            percentage: percentage_items(budget_lines)
          }
        }.to_json
      end

    end
  end

  private
  def per_person_items(budget_lines)
    per_inhabitant = budget_lines.sort_by{|bl| bl.budget_per_inhabitant.to_f }
    min = per_inhabitant.first.budget_per_inhabitant.to_f
    max = per_inhabitant.last.budget_per_inhabitant.to_f
    range = max - min
    width = range / 20

    cuts = {}
    (min...max).step(width).each do |f|
      bucket = (f..f+width)
      cuts[bucket] = per_inhabitant.select {|bl| bucket.include?(bl.budget_per_inhabitant.to_f)}
    end

    cut_number = 0
    items = []
    cuts.each_pair do |cut,budget_lines|
      budget_lines.each do |bl|
        item = {}
        item['name'] = bl.place_name
        item['cut'] = cut_number
        item['label'] = "de #{cut.begin.round(2)}€ a #{cut.end.round(2)}€"
        item['value'] = bl.budget_per_inhabitant.to_f.round(2)
        items << item
      end
      cut_number += 1
    end
    items
  end

  def percentage_items(budget_lines)
    
    percentage_method = if budget_lines.first.respond_to?(:percentage_total_functional)
      :percentage_total_functional
    else
      :percentage_total_economic
    end

    percentage = budget_lines.sort_by{ |bl| bl.send(percentage_method).to_f }
    width = 5

    cuts = {}
    (0...100).step(width).each do |i|
      bucket = (i..i+width)
      cuts[bucket] = percentage.select { |bl| bucket.include?(bl.send(percentage_method).to_f) }
    end

    cut_number = 0
    items = []
    cuts.each_pair do |cut, budget_lines|
      budget_lines.each do |bl|
        item = {}
        item['name'] = bl.place_name
        item['cut'] = cut_number
        item['label'] = "de #{cut.begin}% a #{cut.end}%"
        item['value'] = bl.send(percentage_method).to_f.round(2)
        items << item
      end
      cut_number += 1
    end
    items
  end

end
