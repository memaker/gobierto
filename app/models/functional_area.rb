class FunctionalArea
  INDEX = 'budget-categories'
  TYPE = 'categories'

  EXPENSE = 'G'

  def self.all_items
    @all_items ||= begin
      all_items = {
        EXPENSE => {}
      }

      query = {
        query: {
          filtered: {
            filter: {
              bool: {
                must: [
                  {term: { area: 'functional' }},
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
