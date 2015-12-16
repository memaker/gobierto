class BudgetLine
  INDEX = 'budgets-forecast'

  INCOME = 'I'
  EXPENSE = 'G'

  def self.search(options)
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
                {term: { ine_code: options[:ine_code] }},
                {term: { level: options[:level] }},
                {term: { kind: options[:kind] }},
                {term: { year: options[:year] }}
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

    response = SearchEngine.client.search index: INDEX, type: options[:type], body: query

    return {
      'hits' => response['hits']['hits'].map{ |h| h['_source'] },
      'aggregations' => response['aggregations']
    }
  end
end
