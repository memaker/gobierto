class Data::Treemap
  def initialize(options)
    @place = options[:place]
    @kind = options[:kind]
    @type = options[:type]
    @year = options[:year]
    @parent_code = options[:parent_code]
  end

  def generate_json
    options = [
      {term: { ine_code: @place.id }},
      {term: { kind: @kind }},
      {term: { year: @year }}
    ]

    if @parent_code.nil?
      options.push({term: { level: 1 }})
    else
      options.push({term: { parent_code: @parent_code }})
    end

    query = {
      sort: [
        { amount: { order: 'desc' } }
      ],
      query: {
        filtered: {
          query: {
            match_all: {}
          },
          filter: {
            bool: {
              must: options
            }
          }
        }
      },
      size: 10_000
    }

    areas = @type == 'economic' ? EconomicArea : FunctionalArea

    response = SearchEngine.client.search index: BudgetLine::INDEX, type: @type, body: query
    children_json = response['hits']['hits'].map do |h|
      {
        name: areas.all_items[@kind][h['_source']['code']],
        code: h['_source']['code'],
        budget: h['_source']['amount'],
        budget_per_inhabitant: h['_source']['amount_per_inhabitant']
      }
    end

    return {
      name: @type,
      children: children_json
    }.to_json
  end
end
