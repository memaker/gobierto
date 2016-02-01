class Api::PlacesController < ApplicationController
  def index
    @places = INE::Places::Place.collection_for_search(params[:q])

    respond_to do |format|
      format.json do
        render json: @places.to_json
      end
    end
  end
end
