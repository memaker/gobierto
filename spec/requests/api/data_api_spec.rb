require 'rails_helper'

describe "Data API" do

  describe 'Ranking Widgets' do
    describe 'Total Rankings' do
      it 'returns a title, top_city, top_amount, the ranking url and the names of the 5 top places' do
        get '/api/data/widget/ranking/2015/G/economic/amount.json'

        json = JSON.parse(response.body)

        # test for the 200 status-code
        expect(response).to be_success
        
        expect(json['title']).to eq('Top gastos totales en el 2015')
        expect(json['top_place_name']).to eq("Madrid")
        expect(json['top_amount']).to eq("4.650.554.218 €")
        expect(json['ranking_url']).to eq("/ranking/2015/G/economic/amount")

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
        get '/api/data/widget/ranking/2013/G/functional/per_inhabitant.json'

        json = JSON.parse(response.body)

        # test for the 200 status-code
        expect(response).to be_success
        
        expect(json['title']).to eq('Top gastos por habitante en el 2013')
        expect(json['top_place_name']).to eq("Segura de los Baños")
        expect(json['top_amount']).to eq("32.250 €")
        expect(json['ranking_url']).to eq("/ranking/2013/G/functional/per_inhabitant")

        expect(json['top_5'].length).to eq(5)
        expect(json['top_5']).to include({"place_name" => "Segura de los Baños"})
        expect(json['top_5']).to include({"place_name" => "Hornillos de Cameros"})
      end
    end
  end
end