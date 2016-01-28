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
      },
      size: 10000
    }

    response = SearchEngine.client.search index: INDEX, type: TYPE, body: query
    return response['hits']['hits'].map{ |h| h['_source'] }
  end

  def self.for_ranking(year, variable, offset, per_page, filters)
    response = budget_total_query(year: year, variable: variable, filters: filters, offset: offset, per_page: per_page)
    results = response['hits']['hits'].map{|h| h['_source']}
    total_elements = response['hits']['total']
    return results, total_elements
  end

  def self.place_position_in_ranking(year, variable, ine_code, filters)
    response = budget_total_query(year: year, variable: variable, filters: filters, to_rank: true)

    buckets = response['hits']['hits'].map{|h| h['_id']}
    id = [ine_code, year].join('/')
    position = buckets.index(id) ? buckets.index(id) + 1 : 0;
    return position
  end

  def self.budget_total_query(options)
    population_filter = options[:filters].present? ? options[:filters][:population] : nil
    
    if (population_filter && (population_filter[:from].to_i > Population::FILTER_MIN || population_filter[:to].to_i < Population::FILTER_MAX))
      pop_results,total_elements = Population.for_ranking(options[:year], 0, nil, options[:filters])
      ine_codes = pop_results.map{|p| p['ine_code']}
    end

    terms = [{term: { year: options[:year] }}]
    terms << [{terms: { ine_code: ine_codes }}] if ine_codes
    
    query = {
      sort: [
        { options[:variable].to_sym => { order: 'desc' } }
      ],
      query: {
        filtered: {
          filter: {
            bool: {
              must: terms
            }
          }
        }
      },
      size: 10000
    }
    query.merge!(size: options[:per_page]) if options[:per_page].present?
    query.merge!(from: options[:offset]) if options[:offset].present?
    query.merge!(_source: false) if options[:to_rank]
    
    SearchEngine.client.search index: BudgetTotal::INDEX, type: BudgetTotal::TYPE, body: query
  end
end
