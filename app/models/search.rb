class Search
  def initialize(options)
    @variations  = options[:variations]
    @date_ranges = options[:date_ranges]
    @geo         = options[:geo]
    @datasets    = Hash[Dataset.where(code: @variations).map do |dataset|
      [dataset.code, dataset]
    end]
  end

  def search
    response = SearchEngine.client.search index: 'es', type: @variations, body: search_query

    values = response['hits']['hits'].map do |h|
      h['_source'].merge({
        formatted_date: @datasets[h['_source']['code']].format_date(h['_source']['date']),
        formatted_value: @datasets[h['_source']['code']].format_value(h['_source']['value']),
      })
    end

    return {
      datasets: @datasets.values,
      values: values
    }
  end

  private

  def search_query
    query = {
      query: {
        filtered: {
          query: {}
        }
      },
      sort: {
        date: "desc"
      },
      size: 100_000
    }

    if @geo.present?
      query[:query][:filtered][:query] = query[:query][:filtered][:query].deep_merge(wildcard: { location: @geo })
    else
      query[:query][:filtered][:query] = query[:query][:filtered][:query] = { match_all: {} }
    end

    if @date_ranges.any?
      ranges = @date_ranges.map do |range|
        {
          range: {
            date: { gte: range.first, lte: "#{range.last}-12-31"}
          }
        }
      end

      query[:query][:filtered] = query[:query][:filtered].deep_merge({filter: { or: ranges }})
    end

    query
  end
end
