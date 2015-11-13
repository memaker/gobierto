class Api::DataController < ApplicationController
  def functional
    respond_to do |format|
      format.json do
        render json: {
          title: 'Gastos por áreas funcionales',
          budgets: [
            {
              name: 'Deuda pública',
              per_person: 1111111,
              percentage: 22,
              mean_national: 1123123,
              mean_autonomy: 22222,
              mean_province: 3333
            },
            {
              name: 'Servicios públicos',
              per_person: 213123,
              percentage: 60,
              mean_national: 23123,
              mean_autonomy: 23123,
              mean_province: 234123
            },
            {
              name: 'Protección social',
              per_person: 1232,
              percentage: 10,
              mean_national: 1200,
              mean_autonomy: 12323,
              mean_province: 2321
            }
          ]
        }.to_json
      end
    end
  end


  def economic

  end
end
