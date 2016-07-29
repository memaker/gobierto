module GobiertoBudgets
  module Api
    class IntelligenceController < ApplicationController
      def budget_lines
        place = INE::Places::Place.find params[:ine_code]
        render_404 and return if place.nil?
        years = params[:years].split(',').map(&:to_i)
        render_404 and return if years.size != 2

        query = {
          query: {
            filtered: {
              query: {
                match_all: {}
              },
              filter: {
                bool: {
                  must: [
                    {term: { ine_code: place.id }},
                    {term: { level: 3 }},
                    {terms: { year: years }},
                  ]
                }
              }
            }
          },
          size: 10_000
        }
        response = GobiertoBudgets::SearchEngine.client.search index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast, type: GobiertoBudgets::BudgetLine::FUNCTIONAL, body: query

        respond_to do |format|
          format.json do
            render json: response['hits']['hits'].map{|g| g['_source'] }.to_json
          end
        end
      end
    end
  end
end
