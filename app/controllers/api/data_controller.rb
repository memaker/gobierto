class Api::DataController < ApplicationController
  def functional
    year = params[:year].to_i
    place = INE::Places::Place.find(params[:place_id])

    respond_to do |format|
      budgets = {
        per_person: [
          {
            name: 'Deuda pública',
            value: 1111111,
            mean_national: 1123123,
            mean_autonomy: 22222,
            mean_province: 3333,
          },
          {
            name: 'Servicios públicos',
            value: 1111111,
            mean_national: 1123123,
            mean_autonomy: 22222,
            mean_province: 3333,
          }
        ],
        percentage: [
          {
            name: 'Deuda pública',
            value: 11,
            mean_national: 12,
            mean_autonomy: 10,
            mean_province: 20,
          },
          {
            name: 'Servicios públicos',
            value: 30,
            mean_national: 22,
            mean_autonomy: 25,
            mean_province: 10,
          }
        ]
      }

      total = FunctionalArea.total_budget(place.id, year)

      budgets = {
        per_person: FunctionalArea.root_items.map do |item|
          {
            name: item.name,
            value: item.budget_per_person(place, year),
            mean_national: item.mean_national_per_person(year),
            mean_autonomy: item.mean_autonomy_per_person(year, place),
            mean_province: item.mean_province_per_person(year, place)
          }
        end,
        percentage: FunctionalArea.root_items.map do |item|
          {
            name: item.name,
            value: item.budget_percentage_total(place, year, total),
            mean_national: item.mean_national_percentage(year, total),
            mean_autonomy: item.mean_autonomy_percentage(year, place, total),
            mean_province: item.mean_province_percentage(year, place, total),
          }
        end
      }

      format.json do
        render json: {
          title: 'Gastos por áreas funcionales',
          budgets: budgets
        }.to_json
      end
    end
  end


  def economic

  end
end
