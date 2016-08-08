require 'rails_helper'

describe "Data API" do

  before do
    host! 'presupuestos.' + Settings.gobierto_host
  end

  describe 'Ranking Widgets' do
    describe 'Total Rankings' do
      it 'returns a title, top_city, top_amount, the ranking url and the names of the 5 top places' do
        get '/api/data/widget/ranking/2015/G/economic/amount.json'

        json = JSON.parse(response.body)

        # test for the 200 status-code
        expect(response).to be_success

        expect(json['title']).to eq('Top gastos totales en el 2015')
        expect(json['top_place_name']).to eq("Madrid")
        expect(json['top_amount']).to eq("4.382.585.028 €")
        expect(json['ranking_path']).to eq("/ranking/2015/G/economic/amount")

        expect(json['top_5'].length).to eq(5)
        expect(json['top_5']).to include({"place_name" => "Madrid"})
        expect(json['top_5']).to include({"place_name" => "Barcelona"})
        expect(json['top_5']).to include({"place_name" => "Sevilla"})
        expect(json['top_5']).to include({"place_name" => "Valencia"})
        expect(json['top_5']).to include({"place_name" => "Zaragoza"})
      end
    end

    describe 'Total Per Inhabitant Rankings' do
      it 'returns a title, top_city and top_amount and the names of the 5 top places' do
        get '/api/data/widget/ranking/2013/G/functional/amount_per_inhabitant.json'

        json = JSON.parse(response.body)

        # test for the 200 status-code
        expect(response).to be_success

        expect(json['title']).to eq('Top gastos por habitante en el 2013')
        expect(json['top_place_name']).to eq("Segura de los Baños")
        expect(json['top_amount']).to eq("32.250 €")
        expect(json['ranking_path']).to eq("/ranking/2013/G/functional/amount_per_inhabitant")

        expect(json['top_5'].length).to eq(5)
        expect(json['top_5']).to include({"place_name" => "Segura de los Baños"})
        expect(json['top_5']).to include({"place_name" => "Hornillos de Cameros"})
      end
    end

    describe 'Budget Line Per Inhabitant Rankings' do
      it 'returns a title, top_city, top_amount, ranking_path and the names of the 5 top places' do
        get '/api/data/widget/ranking/2011/G/functional/amount_per_inhabitant/33.json'

        json = JSON.parse(response.body)

        # test for the 200 status-code
        expect(response).to be_success

        expect(json['title']).to eq('Top gastos por habitante en Cultura en el 2011')
        expect(json['top_place_name']).to eq("Daroca de Rioja")
        expect(json['top_amount']).to eq("8.815 €")
        expect(json['ranking_path']).to eq("/ranking/2011/G/functional/amount_per_inhabitant/33")

        expect(json['top_5'].length).to eq(5)
        expect(json['top_5']).to include({"place_name" => "Torre en Cameros"})
        expect(json['top_5']).to include({"place_name" => "Valdemadera"})
      end

      it 'works also for Income' do
        get '/api/data/widget/ranking/2015/I/economic/amount_per_inhabitant/10.json'

        json = JSON.parse(response.body)

        # test for the 200 status-code
        expect(response).to be_success

        expect(json['title']).to eq('Top ingresos por habitante en Impuesto sobre la Renta en el 2015')
        expect(json['top_place_name']).to eq("Pozuelo de Alarcón")
        expect(json['top_amount']).to eq("72 €")
        expect(json['ranking_path']).to eq("/ranking/2015/I/economic/amount_per_inhabitant/10")

        expect(json['top_5'].length).to eq(5)
        expect(json['top_5']).to include({"place_name" => "Rozas de Madrid, Las"})
        expect(json['top_5']).to include({"place_name" => "Sant Cugat del Vallès"})
        expect(json['top_5']).to include({"place_name" => "Alcobendas"})
        expect(json['top_5']).to include({"place_name" => "Madrid"})
      end
    end

    describe 'Budget Line Total Rankings' do
      it 'returns a title, top_city, top_amount, ranking_path and the names of the 5 top places' do
        get '/api/data/widget/ranking/2015/G/functional/amount/33.json'

        json = JSON.parse(response.body)

        # test for the 200 status-code
        expect(response).to be_success

        expect(json['title']).to eq('Top gastos totales en Cultura en el 2015')
        expect(json['top_place_name']).to eq("Madrid")
        expect(json['top_amount']).to eq("138.075.088 €")
        expect(json['ranking_path']).to eq("/ranking/2015/G/functional/amount/33")

        expect(json['top_5'].length).to eq(5)
        expect(json['top_5']).to include({"place_name" => "Barcelona"})
        expect(json['top_5']).to include({"place_name" => "Valencia"})
        expect(json['top_5']).to include({"place_name" => "Málaga"})
        expect(json['top_5']).to include({"place_name" => "Donostia/San Sebastián"})
      end

      it 'works also for Income' do
        get '/api/data/widget/ranking/2015/I/economic/amount/10.json'

        json = JSON.parse(response.body)

        # test for the 200 status-code
        expect(response).to be_success

        expect(json['title']).to eq('Top ingresos totales en Impuesto sobre la Renta en el 2015')
        expect(json['top_place_name']).to eq("Madrid")
        expect(json['top_amount']).to eq("110.575.079 €")
        expect(json['ranking_path']).to eq("/ranking/2015/I/economic/amount/10")

        expect(json['top_5'].length).to eq(5)
        expect(json['top_5']).to include({"place_name" => "Barcelona"})
        expect(json['top_5']).to include({"place_name" => "Valencia"})
        expect(json['top_5']).to include({"place_name" => "Zaragoza"})
        expect(json['top_5']).to include({"place_name" => "Sevilla"})
      end
    end
  end

  describe 'Deviation Widget' do
    describe 'Expenditure' do
      it 'returns a dev. heading, summary, percentage, total budgeted and total executed' do
        get '/api/data/widget/budget_execution_deviation/39075/2015/G.json'

        json = JSON.parse(response.body)

        # test for the 200 status-code
        expect(response).to be_success

        expect(json['deviation_heading']).to eq('Desviación de los gastos en 2015')
        expect(json['total_budgeted']).to eq('188M€')
        expect(json['total_executed']).to eq('173M€')
        expect(json['deviation_percentage']).to eq('-7,87')
        expect(json['deviation_summary']).to eq('Se ha gastado un 7,87% (15M€) menos de lo planeado')
      end
    end

    describe 'Income' do
      pending 'returns a dev. heading, summary, percentage, total budgeted and total executed' do
        get '/api/data/widget/budget_execution_deviation/39075/2014/I.json'

        json = JSON.parse(response.body)

        # test for the 200 status-code
        expect(response).to be_success

        expect(json['deviation_heading']).to eq('Desviación de los ingresos en 2014')
        expect(json['deviation_summary']).to eq('Se ha ingresado un X,XX% (XM€) más de lo planeado')
        expect(json['deviation_percentage']).to eq('X,XX%')
        expect(json['total_budgeted']).to eq('XXXM')
        expect(json['total_executed']).to eq('XXXM')
      end
    end
  end
end
