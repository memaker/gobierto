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

    query[:query][:filtered][:filter][:bool][:must] << {term: { parent_code: options[:parent_code] }} if options[:parent_code].present?
    query[:query][:filtered][:filter][:bool][:must] << {term: { level: options[:level] }} if options[:level].present?
    query[:query][:filtered][:filter][:bool][:must] << {term: { code: options[:code] }} if options[:code].present?

    response = SearchEngine.client.search index: INDEX, type: (options[:type] || 'economic'), body: query

    return {
      'hits' => response['hits']['hits'].map{ |h| h['_source'] },
      'aggregations' => response['aggregations']
    }
  end

  def self.find(options)
    return self.search(options)['hits'][0]
  end
end
