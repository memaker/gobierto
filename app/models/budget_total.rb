class BudgetTotal
  INDEX = 'budgets-forecast'
  TYPE = 'total-budget'

  def self.for(ine_code, year)
    return for_places(ine_code, year) if ine_code.is_a?(Array)

    result = SearchEngine.client.get index: BudgetTotal::INDEX, type: BudgetTotal::TYPE, id: [ine_code, year].join('/')
    result['_source']['total_budget'].to_f
  end

  def self.for_places(ine_codes, year)
    terms = [{terms: {ine_code: ine_codes}},
             {term: {year: year}}]

    query = {
      query: {
        filtered: {
          filter: {
            bool: {
              must: terms
            }
          }
        }
      }
    }

    response = SearchEngine.client.search index: INDEX, type: TYPE, body: query
    return response['hits']['hits'].map{ |h| h['_source'] }
  end
end
