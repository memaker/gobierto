class Api::DataController < ApplicationController
  def functional
    year = params[:year].to_i
    place = INE::Places::Place.find(params[:place_id])

    respond_to do |format|
      budgets = [
        {
          name: 'Deuda pública',
          per_person: {
            value: 1111111,
            mean_national: 1123123,
            mean_autonomy: 22222,
            mean_province: 3333,
          },
          percentage: {
            value: 22,
            mean_national: 25,
            mean_autonomy: 22,
            mean_province: 20
          }
        },
        {
          name: 'Servicios públicos',
          per_person: {
            value: 1111111,
            mean_national: 1123123,
            mean_autonomy: 22222,
            mean_province: 3333,
          },
          percentage: {
            value: 22,
            mean_national: 25,
            mean_autonomy: 22,
            mean_province: 20
          }
        },
        {
          name: 'Protección social',
          per_person: {
            value: 1111111,
            mean_national: 1123123,
            mean_autonomy: 22222,
            mean_province: 3333,
          },
          percentage: {
            value: 22,
            mean_national: 25,
            mean_autonomy: 22,
            mean_province: 20
          }
        }
      ]

      #budgets = FunctionalArea.root_items.map do |item|
        #{
          #name: item.name,
          #per_person: item.budget_per_person(place, year),
          #percentage: 0,
          #mean_national: 1200,
          #mean_autonomy: 12323,
          #mean_province: 2321
        #}
      #end

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
