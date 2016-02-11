class BudgetLine < OpenStruct
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

  def self.budget_line_query(options)
    query = {
      sort: [ { options[:variable].to_sym => { order: 'desc' } } ],
      query: {
        filtered: {
          filter: {
            bool: {
              must: [
                {term: { year: options[:year] }},
                {term: { kind: options[:kind] }},
                {term: { code: options[:code] }}
              ]
            }
          }
        }
      },
      size: 10_000
    }

    query.merge!(size: options[:per_page]) if options[:per_page].present?
    query.merge!(from: options[:offset]) if options[:offset].present?
    query.merge!(_source: false) if options[:to_rank]

    SearchEngine.client.search index: BudgetLine::INDEX, type: options[:area_name], body: query
  end

  def self.find(options)
    return self.search(options)['hits'][0]
  end

  def self.for_ranking(options)
    response = budget_line_query(options)
    results = response['hits']['hits'].map{|h| h['_source']}
    total_elements = response['hits']['total']

    return results, total_elements
  end

  def self.place_position_in_ranking(options)
    id = %w{ine_code year code kind}.map {|f| options[f.to_sym]}.join('/')
    
    response = budget_line_query(options.merge(to_rank: true))
    buckets = response['hits']['hits'].map{|h| h['_id']}
    return buckets.index(id) + 1
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

  def to_param
    {place_id: place_id, year: year, code: code, area_name: area_name, kind: kind}
  end

  def place
    if place_id
      INE::Places::Place.find(place_id)
    end
  end

  def category
    area = area_name == 'economic' ? EconomicArea : FunctionalArea
    area.all_items[self.kind][self.code]
  end
end
