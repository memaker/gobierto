class BudgetLine
  INDEX = 'budgets-forecast'

  INCOME = 'I'
  EXPENSE = 'G'

  def self.search(options)

    terms = [{term: { kind: options[:kind] }},
            {term: { year: options[:year] }}]

    terms << {term: { ine_code: options[:ine_code] }} if options[:ine_code].present?
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

  def self.compare_with_ancestors(options)
    terms = [{terms: { ine_code: options[:ine_codes] }},
              {term: { kind: options[:kind] }},
              {term: { year: options[:year] }},
              {range: { level: { lte: options[:level].to_i } }},
              {bool: {
                should: [
                  {wildcard: { code: "#{options[:parent_code][0]}*" }},
                  {term: { parent_code: '' }}
                  ]
                }
              }]
    
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

  def self.has_children?(budget_line, area)
    options = { parent_code: budget_line['code'],
                level: budget_line['level'].to_i + 1,
                type: area }
    options.merge! budget_line.slice('ine_code','kind','year').symbolize_keys
    
    return search(options)['hits'].length > 0
  end
end
