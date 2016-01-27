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

  # Returns the position of a place in a ranking. The ranking is determined by the field
  # parameter
  def self.place_position(options)
    year = options[:year]
    ine_code = options[:ine_code]
    code = options[:code]
    kind = options[:kind]
    area = options[:area]
    field = options[:field]

    if code.present?
      query = {
        sort: [ { field.to_sym => { order: 'desc' } } ],
        query: {
          filtered: {
            filter: {
              bool: {
                must: [
                  {term: { year: year }},
                  {term: { kind: kind }},
                  {term: { code: code }}
                ]
              }
            }
          }
        },
        size: 10_000,
        _source: false
      }

      id = [ine_code, year, code, kind].join('/')

      response = SearchEngine.client.search index: BudgetLine::INDEX, type: area, body: query
      buckets = response['hits']['hits'].map{|h| h['_id']}
      return buckets.index(id).nil? ? nil : buckets.index(id) + 1
    else
      if field == 'population'
        query = {
          sort: [
            { value: { order: 'desc' } }
          ],
          query: {
            filtered: {
              filter: {
                bool: {
                  must: [
                    {term: { year: year }}
                  ]
                }
              }
            }
          },
          size: 10_000,
          _source: false
        }
        id = [ine_code, year].join('/')
        response = SearchEngine.client.search index: Population::INDEX, type: Population::TYPE, body: query
        buckets = response['hits']['hits'].map{|h| h['_id']}
        return buckets.index(id).nil? ? nil : buckets.index(id) + 1
      else
        field = (field == 'amount') ? 'total_budget' : 'total_budget_per_inhabitant'
<<<<<<< 0aa04c05c56875b8fcf80e65f898abe73d364529

        query = {
          sort: [
            { field.to_sym => { order: 'desc' } }
          ],
          query: {
            filtered: {
              filter: {
                bool: {
                  must: [
                    {term: { year: year }}
                  ]
                }
              }
            }
          },
          size: 10_000,
          _source: false
        }

        id = [ine_code, year].join('/')

        response = SearchEngine.client.search index: BudgetTotal::INDEX, type: BudgetTotal::TYPE, body: query
        buckets = response['hits']['hits'].map{|h| h['_id']}
        return buckets.index(id).nil? ? nil : buckets.index(id) + 1
=======
        return BudgetTotal.place_position_in_ranking(year, field, ine_code)
>>>>>>> Refactored Place Position to BudgetTotal
      end
    end
  end

  ## Private

  def self.budget_line_ranking(variable, year, code, kind, area_name, offset)
    query = {
      sort: [ { variable.to_sym => { order: 'desc' } } ],
      query: {
        filtered: {
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
    
    results, total_elements = Population.for_ranking(year,offset,self.per_page)
    
    places_ids = results.map{|h| h['ine_code']}
    total_results = BudgetTotal.for_places(places_ids, year)
    
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
    
    results, total_elements = BudgetTotal.for_ranking(year, variable, offset, self.per_page)

    places_ids = results.map {|h| h['ine_code']}
    population_results = Population.for_places(places_ids, year)

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
