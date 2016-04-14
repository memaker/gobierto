module GobiertoBudgets
    class SearchController < GobiertoBudgets::ApplicationController

    def index
      respond_to do |format|
        format.json do
          render json: {
            suggestions: Place.search(params[:query])
          }.to_json
        end
      end
    end

    def categories
      year = params[:year].to_i
      area = params[:area]
      kind = params[:kind]
      place = INE::Places::Place.find_by_slug(params[:slug])

      this_year_codes = get_year_codes(place, area, kind, year)

      klass_name = params[:area] == 'economic' ? EconomicArea : FunctionalArea
      query = params[:query].downcase
      suggestions = klass_name.all_items[params[:kind]].select{|k,v| this_year_codes.include?(k) && v.downcase.include?(query) }

      respond_to do |format|
        format.json do
          render json: {
            suggestions: suggestions.map do |k,v|
              {
                value: "#{v} (#{k})",
                data: {
                  url: gobierto_budgets_budget_line_path(place.slug, year, k, kind, area)
                }
              }
            end
          }.to_json
        end
      end
    end

    private

    def get_year_codes(place, area, kind, year)
      query = {
        query: {
          filtered: {
            filter: {
              bool: {
                must: [
                  {term: { ine_code: place.id }},
                  {term: { kind: kind}},
                  {term: { year: year }},
                ]
              }
            }
          }
        },
        size: 10_000
      }

      response = GobiertoBudgets::SearchEngine.client.search index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast, type: area, body: query
      response['hits']['hits'].map{|h| h['_source']['code'] }
    end
  end
end
