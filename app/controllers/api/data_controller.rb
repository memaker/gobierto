class Api::DataController < ApplicationController

  def treemap
    query = {
      sort: [
        { code: { order: 'asc' } }
      ],
      query: {
        filtered: {
          query: {
            match_all: {}
          },
          filter: {
            bool: {
              must: [
                {term: { ine_code: params[:ine_code] }},
                {term: { level: params[:level] }},
                {term: { kind: params[:kind] }},
                {term: { year: params[:year] }}
              ]
            }
          }
        }
      },
      size: 10_000
    }

    areas = params[:type] == 'economic' ? EconomicArea : FunctionalArea
    kind = params[:kind].to_i == '0' ? 'I' : 'G'

    response = SearchEngine.client.search index: BudgetLine::INDEX, type: params[:type], body: query
    children_json = response['hits']['hits'].map do |h|
      {
        name: areas.all_items[kind][h['_source']['code']],
        budget: h['_source']['amount'],
        budget_per_inhabitant: h['_source']['amount_per_inhabitant']
      }
    end

    respond_to do |format|
      format.json do
        render json: {
          name: "economic",
          "children": children_json
        }.to_json
      end
    end
  end

end
