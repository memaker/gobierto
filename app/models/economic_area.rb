class EconomicArea
  INDEX = 'budget-categories'
  TYPE = 'categories'

  EXPENSE = 'G'
  INCOME  = 'I'

  def self.all_items
    @all_items ||= begin
      all_items = {
        EXPENSE => {},
        INCOME => {}
      }

      query = {
        query: {
          filtered: {
            query: {
              match_all: {}
            },
            filter: {
              bool: {
                must: [
                  {term: { area: 'economic' }},
                ]
              }
            }
          }
        },
        size: 10_000
      }
      response = SearchEngine.client.search index: INDEX, type: TYPE, body: query

      response['hits']['hits'].each do |h|
        source = h['_source']
        all_items[source['kind']][source['code']] = source['name']
      end

      all_items
    end
  end
end
