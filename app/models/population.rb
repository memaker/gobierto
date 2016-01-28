class Population
  INDEX = 'data'
  TYPE = 'population'
  FILTER_MIN = 0
  FILTER_MAX = 5000000

  def self.for(ine_code, year)
    return for_places(ine_code, year) if ine_code.is_a?(Array)
    population_query_results(ine_code: ine_code, year: year).first['value'].to_f
  end

  def self.for_places(ine_codes, year)
    population_query_results(ine_codes: ine_codes, year: year)
  end

  def self.for_year(year)
    population_query_results(year: year)
  end

  def self.for_ranking(year, offset, per_page, filters)
    population_filter = filters.present? ? filters[:population] : {}
    response = population_query(year: year, offset: offset, per_page: per_page, filters: population_filter)
    total_elements = response['hits']['total']
    return response['hits']['hits'].map{|h| h['_source']}, total_elements
  end

  def self.ranking_hash_for(ine_code, year)
    buckets = for_year year

    if row = buckets.detect{|v| v['ine_code'] == ine_code }
      value = row['value']
    end

    position = buckets.index(row) + 1 rescue nil

    return {
      value: value,
      position: position,
      total_elements: buckets.length
    }
  end

  def self.place_position_in_ranking(year, ine_code, filters)
    id = [ine_code, year].join('/')
    population_filter = filters.present? ? filters[:population] : {}
    response = population_query({year: year, to_rank: true, filters: population_filter})
    buckets = response['hits']['hits'].map{|h| h['_id']}
    position = buckets.index(id) ? buckets.index(id) + 1 : 0;
    return position + 1
  end

  private
  def self.population_query(options)
    terms = []
    terms << {terms: { ine_code: options[:ine_codes] }} if options[:ine_codes].present?
    terms << {term: { ine_code: options[:ine_code] }} if options[:ine_code].present?
    terms << {term: { year: options[:year] }}
    terms << {range: { value: { gte: options[:filters][:from].to_i, lte: options[:filters][:to].to_i} }} if options[:filters].present?

    query = {
      sort: [
        { value: { order: 'desc' } }
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
      size: 10_000
    }

    query.merge!(size: options[:per_page]) if options[:per_page].present?
    query.merge!(from: options[:offset]) if options[:offset].present?
    query.merge!(_source: false) if options[:to_rank]

    SearchEngine.client.search index: Population::INDEX, type: Population::TYPE, body: query
  end

  def self.population_query_results(options)
    population_query(options)['hits']['hits'].map{|h| h['_source']}
  end

end
