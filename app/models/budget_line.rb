class BudgetLine
  INDEX = 'budgets-forecast'

  INCOME = 'I'
  EXPENSE = 'G'

  def self.search(options)

    terms = [{term: { ine_code: options[:ine_code] }},
            {term: { kind: options[:kind] }},
            {term: { year: options[:year] }}]

    terms << {term: { parent_code: options[:parent_code] }} if options[:parent_code].present?
    terms << {term: { level: options[:level] }} if options[:level].present?
    terms << {term: { code: options[:code] }} if options[:code].present?

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
              must: terms
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

    response = SearchEngine.client.search index: INDEX, type: (options[:type] || 'economic'), body: query

    return {
      'hits' => response['hits']['hits'].map{ |h| h['_source'] },
      'aggregations' => response['aggregations']
    }
  end

  def self.find(options)
    return self.search(options)['hits'][0]
  end

  def self.compare(options)
    terms = [{terms: { ine_code: options[:ine_codes] }},
             {term: { level: options[:level] }},
             {term: { kind: options[:kind] }},
             {term: { year: options[:year] }}]

    terms << {term: { parent_code: options[:parent_code] }} if options[:parent_code].present?
    terms << {term: { code: options[:code] }} if options[:code].present?

    query = {
      sort: [
        { code: { order: 'asc' } },
        { ine_code: { order: 'asc' }}
      ],
      query: {
        filtered: {
          query: {
            match_all: {}
          },
          filter: {
            bool: {
              must: terms
            }
          }
        }
      },
      size: 10_000
    }

    response = SearchEngine.client.search index: INDEX, type: options[:type] , body: query
    response['hits']['hits'].map{ |h| h['_source'] }
  end
end
