namespace :total_budget do
  TOTAL_BUDGET_INDEXES = ['budgets-forecast', 'budgets-execution']
  TOTAL_BUDGET_TYPES = ['total-budget']

  def create_mapping(index, type)
    m = SearchEngine.client.indices.get_mapping index: index, type: type
    return unless m.empty?

    # Document identifier: <ine_code>/<year>
    #
    # Example: 28079/2015
    # Example: 28079/2015
    SearchEngine.client.indices.put_mapping index: index, type: type, body: {
      type.to_sym => {
        properties: {
          ine_code:                    { type: 'integer', index: 'not_analyzed' },
          province_id:                 { type: 'integer', index: 'not_analyzed' },
          autonomy_id:                 { type: 'integer', index: 'not_analyzed' },
          year:                        { type: 'integer', index: 'not_analyzed' },
          total_budget:                { type: 'double',  index: 'not_analyzed' },
          total_budget_per_inhabitant: { type: 'double',  index: 'not_analyzed' }
        }
      }
    }
  end

  def get_data(index,place,year)
    # total budget in a place
    query = {
      query: {
        filtered: {
          query: {
            match_all: {}
          },
          filter: {
            bool: {
              must: [
                {term: { ine_code: place.id }},
                {term: { level: 1 }},
                {term: { kind: 'G' }},
                {term: { year: year }}
              ]
            }
          }
        }
      },
      aggs: {
        total_budget: { sum: { field: 'amount' } },
        total_budget_per_inhabitant: { sum: { field: 'amount_per_inhabitant' } },
      },
      size: 0
    }

    result = SearchEngine.client.search index: index, type: 'functional', body: query
    return result['aggregations']['total_budget']['value'].round(2), result['aggregations']['total_budget_per_inhabitant']['value'].round(2)
  end

  def import_total_budget(year, index)
    pbar = ProgressBar.new("total-#{year}", INE::Places::Place.all.length)

    INE::Places::Place.all.each do |place|
      pbar.inc
      total_budget, total_budget_per_inhabitant = get_data(index, place, year)

      data = {
        ine_code: place.id.to_i, province_id: place.province.id.to_i,
        autonomy_id: place.province.autonomous_region.id.to_i, year: year,
        total_budget: total_budget,
        total_budget_per_inhabitant: total_budget_per_inhabitant
      }

      id = [place.id,year].join("/")
      SearchEngine.client.index index: index, type: TOTAL_BUDGET_TYPES.first, id: id, body: data
    end

    pbar.finish
  end

  desc 'Reset ElasticSearch'
  task :reset => :environment do
    TOTAL_BUDGET_INDEXES.each do |index|
      if SearchEngine.client.indices.exists? index: index
        puts "- Deleting #{index} index"
        SearchEngine.client.indices.delete index: index
      end
    end
  end

  desc 'Create mappings'
  task :create => :environment do
    TOTAL_BUDGET_INDEXES.each do |index|
      unless SearchEngine.client.indices.exists? index: index
        puts "- Creating index #{index}"
        SearchEngine.client.indices.create index: index, body: {
          settings: {
            # Allow 100_000 results per query
            index: { max_result_window: 100_000 }
          }
        }
      end

      TOTAL_BUDGET_TYPES.each do |type|
        puts "- Creating #{index} > #{type}"
        create_mapping(index, type)
      end
    end
  end

  desc "Import total budgets. Example rake total_budget:import['budgets-execution',2014]"
  task :import, [:index,:year] => :environment do |t, args|
    index = args[:index] if TOTAL_BUDGET_INDEXES.include?(args[:index])
    raise "Invalid index #{args[:index]}" if index.blank?

    if m = args[:year].match(/\A\d{4}\z/)
      year = m[0].to_i
    end

    import_total_budget(year, index)
  end
end
