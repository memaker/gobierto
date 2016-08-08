module GobiertoBudgets
  class BudgetTotal
    TOTAL_FILTER_MIN = 0
    TOTAL_FILTER_MAX = 5000000000
    PER_INHABITANT_FILTER_MIN = 0
    PER_INHABITANT_FILTER_MAX = 20000
    BUDGET_SEL = 'B'
    EXECUTION_SEL = 'E'

    def self.budgeted_for(ine_code, year)
      return BudgetTotal.for(ine_code, year, BudgetTotal::BUDGET_SEL)
    end

    def self.execution_for(ine_code, year)
      return BudgetTotal.for(ine_code, year, BudgetTotal::EXECUTION_SEL)
    end

    def self.for(ine_code, year, b_or_e = BudgetTotal::BUDGET_SEL)
      return for_places(ine_code, year) if ine_code.is_a?(Array)
      index = (b_or_e == BudgetTotal::EXECUTION_SEL) ? SearchEngineConfiguration::TotalBudget.index_executed : SearchEngineConfiguration::TotalBudget.index_forecast

      result = SearchEngine.client.get index: index, type: SearchEngineConfiguration::TotalBudget.type, id: [ine_code, year, BudgetLine::EXPENSE].join('/')
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

      response = SearchEngine.client.search index: SearchEngineConfiguration::TotalBudget.index_forecast, type: SearchEngineConfiguration::TotalBudget.type, body: query
      return response['hits']['hits'].map{ |h| h['_source'] }
    end

    def self.for_ranking(year, variable, offset, per_page, filters = {})
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
      terms = [{term: { year: options[:year] }}]

      if options[:filters].present?
        population_filter =  options[:filters][:population]
        total_filter = options[:filters][:total]
        per_inhabitant_filter = options[:filters][:per_inhabitant]
        aarr_filter = options[:filters][:aarr]
      end

      if (population_filter && (population_filter[:from].to_i > Population::FILTER_MIN || population_filter[:to].to_i < Population::FILTER_MAX))
        reduced_filter = {population: population_filter}
        reduced_filter.merge!(aarr: aarr_filter) if aarr_filter
        results,total_elements = Population.for_ranking(options[:year], 0, nil, reduced_filter)
        ine_codes = results.map{|p| p['ine_code']}
        terms << [{terms: { ine_code: ine_codes }}] if ine_codes.any?
      end

      if (total_filter && (total_filter[:from].to_i > BudgetTotal::TOTAL_FILTER_MIN || total_filter[:to].to_i < BudgetTotal::TOTAL_FILTER_MAX))
        terms << {range: { total_budget: { gte: total_filter[:from].to_i, lte: total_filter[:to].to_i} }}
      end

      if (per_inhabitant_filter && (per_inhabitant_filter[:from].to_i > BudgetTotal::PER_INHABITANT_FILTER_MIN || per_inhabitant_filter[:to].to_i < BudgetTotal::PER_INHABITANT_FILTER_MAX))
        terms << {range: { total_budget_per_inhabitant: { gte: per_inhabitant_filter[:from].to_i, lte: per_inhabitant_filter[:to].to_i} }}
      end

      terms << {term: { autonomy_id: aarr_filter }} unless aarr_filter.blank?

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

      SearchEngine.client.search index: SearchEngineConfiguration::TotalBudget.index_forecast, type: SearchEngineConfiguration::TotalBudget.type, body: query
    end
  end
end
