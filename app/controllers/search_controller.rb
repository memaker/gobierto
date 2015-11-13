class SearchController < ApplicationController

  def index
    respond_to do |format|
      format.json do
        render json: {
          suggestions: search_across_models(params[:query])
        }.to_json
      end
    end
  end

  private

  def search_across_models(query)
    INE::Places::Place.collection_for_search(query) +
      INE::Places::Province.collection_for_search(query) +
      INE::Places::AutonomousRegion.collection_for_search(query)
  end
end
