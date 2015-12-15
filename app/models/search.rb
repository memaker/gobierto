class Search
  def initialize(options = {})
  end

  def search(query)
    response = SearchEngine.client.search index: 'es', type: @variations, body: query

    return response['hits']['hits']
  end

  private

  def search_query
    query = {
      query: {
        filtered: {
          query: {
            match_all: {}
          },
          filter: {
            bool: {
              must: [
                {term: { ine_code: 28079 }},
                {term: { level: 1 }},
                {term: { kind: 1 }},
                {term: { year: 2015 }}
              ]
            }
          }
        }
      },
      aggs: {
        total_budget: { sum: { field: 'amount' } },
        total_budget_per_inhabitant: { sum: { field: 'amount_per_inhabitant' } },
      },
      size: 10_000
    }

    query
  end
end
