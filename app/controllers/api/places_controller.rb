class Api::PlacesController < ApplicationController
  def index
    @places = search_place(params[:q])

    respond_to do |format|
      format.json do
        render json: @places.to_json
      end
    end
  end

  private

  def search_place(query)
    return [] if query.blank? || query.length < 3

    query = {
      query: {
        wildcard: {
          name: "#{query.downcase}*"
        }
      },
      size: 10_000
    }

    response = SearchEngine.client.search index: 'data', type: 'places', body: query
    source = response['hits']['hits'].map{|h| h['_source'] }
    source.map do |place|
      ine_place = INE::Places::Place.find(place['ine_code'])
      next if ine_place.nil?

      {
        value: ine_place.name,
        data: {
          category: ine_place.province.name,
          id: ine_place.id,
          slug: ine_place.slug,
          type: 'Place'
        }
      }
    end.compact
  end
end
