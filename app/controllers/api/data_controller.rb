class Api::DataController < ApplicationController
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
end
