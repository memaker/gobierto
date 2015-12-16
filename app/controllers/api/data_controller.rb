class Api::DataController < ApplicationController

  def treemap
    query = {
      sort: [
        { amount: { order: 'desc' } }
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

    response = SearchEngine.client.search index: BudgetLine::INDEX, type: params[:type], body: query
    children_json = response['hits']['hits'].map do |h|
      {
        name: areas.all_items[params[:kind]][h['_source']['code']],
        budget: h['_source']['amount'],
        budget_per_inhabitant: h['_source']['amount_per_inhabitant']
      }
    end

    respond_to do |format|
      format.json do
        render json: {
          name: params[:type],
          children: children_json
        }.to_json
      end
    end
  end

end
