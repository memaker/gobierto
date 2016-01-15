class Ranking
  # This class is used in the ranking table to provide the information for each row
  class Item < OpenStruct
  end

  def self.per_page
    25
  end

  def self.position(i, page)
    (page - 1)*self.per_page + i + 1
  end

  def self.page_from_position(position)
    (position.to_f / self.per_page.to_f).ceil
  end

  def self.query(options)
    year = options[:year]
    variable = options[:variable]
    page = options[:page]
    code = options[:code]
    kind = options[:kind]
    area_name = options[:area_name]

    offset = (page-1)*self.per_page

    results, total_results = if code
      self.budget_line_ranking(variable, year, code, kind, area_name, offset)
    elsif variable == 'population'
      self.population_ranking(variable, year, offset)
    else
      self.total_budget_ranking(variable, year, offset)
    end

    Kaminari.paginate_array(results, {limit: self.per_page, offset: offset, total_count: total_results})
  end

  def self.budget_line_ranking(variable, year, code, kind, area_name, offset)
    query = {
      sort: [ { variable.to_sym => { order: 'desc' } } ],
      query: {
        filtered: {
          query: { match_all: {} },
          filter: {
            bool: {
              must: [
                {term: { year: year }},
                {term: { code: code }},
                {term: { kind: kind }}
              ]
            }
          }
        }
      },
      from: offset,
      size: self.per_page,
    }
    response = SearchEngine.client.search index: BudgetLine::INDEX, type: area_name, body: query
    total_elements = response['hits']['total']
    results = response['hits']['hits'].map{|h| h['_source']}

    query = {
      query: {
        filtered: {
          query: { match_all: {} },
          filter: {
            bool: {
              must: [ {term: { year: year }}, {terms: { ine_code: results.map{|h| h['ine_code']}}}]
            }
          }
        }
      },
      size: self.per_page,
    }
    response = SearchEngine.client.search index: Population::INDEX, type: Population::TYPE, body: query
    population_results = response['hits']['hits'].map{|h| h['_source']}

    query = {
      query: {
        filtered: {
          query: { match_all: {} },
          filter: {
            bool: {
              must: [ {term: { year: year }}, {terms: { ine_code: results.map{|h| h['ine_code']}}}]
            }
          }
        }
      },
      size: self.per_page,
    }
    response = SearchEngine.client.search index: BudgetTotal::INDEX, type: BudgetTotal::TYPE, body: query
    total_results = response['hits']['hits'].map{|h| h['_source']}

    return results.map do |h|
      id = h['ine_code']
      Item.new({
        place: INE::Places::Place.find(id),
        population: population_results.detect{|h| h['ine_code'] == id}['value'],
        amount_per_inhabitant: h['amount_per_inhabitant'],
        amount: h['amount'],
        total: total_results.detect{|h| h['ine_code'] == id}['total_budget']
      })
    end, total_elements
  end

  def self.population_ranking(variable, year, offset)
    query = {
      sort: [ { value: { order: 'desc' } } ],
      query: {
        filtered: {
          query: { match_all: {} },
          filter: {
            bool: {
              must: [ {term: { year: year }}, ]
            }
          }
        }
      },
      from: offset,
      size: self.per_page,
    }
    response = SearchEngine.client.search index: Population::INDEX, type: Population::TYPE, body: query
    total_elements = response['hits']['total']
    results = response['hits']['hits'].map{|h| h['_source']}

    query = {
      query: {
        filtered: {
          query: { match_all: {} },
          filter: {
            bool: {
              must: [ {term: { year: year }}, {terms: { ine_code: results.map{|h| h['ine_code']}}}]
            }
          }
        }
      },
      size: self.per_page,
    }
    response = SearchEngine.client.search index: BudgetTotal::INDEX, type: BudgetTotal::TYPE, body: query
    total_results = response['hits']['hits'].map{|h| h['_source']}

    return results.map do |h|
      id = h['ine_code']
      Item.new({
        place: INE::Places::Place.find(id),
        population: h['value'],
        amount_per_inhabitant: total_results.detect{|h| h['ine_code'] == id}['total_budget_per_inhabitant'],
        amount: total_results.detect{|h| h['ine_code'] == id}['total_budget'],
        total: total_results.detect{|h| h['ine_code'] == id}['total_budget']
      })
    end, total_elements
  end

  def self.total_budget_ranking(variable, year, offset)
    variable = if variable == 'amount'
                 'total_budget'
               else
                 'total_budget_per_inhabitant'
               end
    query = {
      sort: [ { variable.to_sym => { order: 'desc' } } ],
      query: {
        filtered: {
          query: { match_all: {} },
          filter: {
            bool: {
              must: [ {term: { year: year }}, ]
            }
          }
        }
      },
      from: offset,
      size: self.per_page,
    }
    response = SearchEngine.client.search index: BudgetTotal::INDEX, type: BudgetTotal::TYPE, body: query
    results = response['hits']['hits'].map{|h| h['_source']}
    total_elements = response['hits']['total']

    query = {
      query: {
        filtered: {
          query: { match_all: {} },
          filter: {
            bool: {
              must: [ {term: { year: year }}, {terms: { ine_code: results.map{|h| h['ine_code']}}}]
            }
          }
        }
      },
      size: self.per_page,
    }
    response = SearchEngine.client.search index: Population::INDEX, type: Population::TYPE, body: query
    population_results = response['hits']['hits'].map{|h| h['_source']}

    return results.map do |h|
      id = h['ine_code']
      Item.new({
        place: INE::Places::Place.find(id),
        population: population_results.detect{|h| h['ine_code'] == id}['value'],
        amount_per_inhabitant: h['total_budget_per_inhabitant'],
        amount: h['total_budget'],
        total: h['total_budget']
      })
    end, total_elements
  end

end
