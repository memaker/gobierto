class Population
  INDEX = 'data'
  TYPE = 'population'

  def self.for(ine_code, year)
    return for_places(ine_code, year) if ine_code.is_a?(Array)
    population_query(ine_code: ine_code, year: year).first['value'].to_f
  end

  def self.for_places(ine_codes, year)
    population_query(ine_codes: ine_codes, year: year)
  end

  private
  def self.population_query(options)
    terms = []
    terms << {terms: { ine_code: options[:ine_codes] }} if options[:ine_codes].present?
    terms << {term: { ine_code: options[:ine_code] }} if options[:ine_code].present?
    terms << {term: { year: options[:year] }}
    
    query = {
      sort: [
        { value: { order: 'desc' } }
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
    response = SearchEngine.client.search index: Population::INDEX, type: Population::TYPE, body: query
    response['hits']['hits'].map{|h| h['_source']}
  end
end