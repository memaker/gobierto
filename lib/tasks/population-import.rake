namespace :population do
  POPULATION_INDEXES = ['data']
  POPULATION_TYPES = ['population']

  def create_population_mapping(index, type)
    m = SearchEngine.client.indices.get_mapping index: index, type: type
    return unless m.empty?

    # Document identifier: <ine_code>/<year>
    #
    # Example: 28079/2015
    # Example: 28079/2015
    SearchEngine.client.indices.put_mapping index: index, type: type, body: {
      type.to_sym => {
        properties: {
          ine_code:              { type: 'integer', index: 'not_analyzed' },
          province_id:           { type: 'integer', index: 'not_analyzed' },
          autonomy_id:           { type: 'integer', index: 'not_analyzed' },
          year:                  { type: 'integer', index: 'not_analyzed' },
          value:                 { type: 'integer', index: 'not_analyzed' }
        }
      }
    }
  end

  def import_population(file_path, year)
    pbar = ProgressBar.new("population-#{year}", INE::Places::Place.all.length)

    dataset = PCAxis::Dataset.new file_path
    population_data = dataset.data('edad (año a año)' => 'Total', 'sexo' => 'Ambos sexos')
    places_codes = dataset.dimension('municipios').map{|k| k.split('-').first.to_i }
    population_data = Hash[places_codes.zip(population_data)]

    INE::Places::Place.all.each do |place|
      pbar.inc
      pop = population_data[place.id.to_i]
      if pop.nil?
        puts place.name
        next
      end

      data = {
        ine_code: place.id.to_i, province_id: place.province.id.to_i,
        autonomy_id: place.province.autonomous_region.id.to_i, year: year,
        value: pop.to_i
      }

      id = [place.id,year].join("/")

      SearchEngine.client.index index: POPULATION_INDEXES.first, type: POPULATION_TYPES.first, id: id, body: data
    end

    pbar.finish
  end

  desc 'Reset ElasticSearch'
  task :reset => :environment do
    POPULATION_INDEXES.each do |index|
      if SearchEngine.client.indices.exists? index: index
        puts "- Deleting #{index} index"
        SearchEngine.client.indices.delete index: index
      end
    end
  end

  desc 'Create mappings'
  task :create => :environment do
    POPULATION_INDEXES.each do |index|
      unless SearchEngine.client.indices.exists? index: index
        puts "- Creating index #{index}"
        SearchEngine.client.indices.create index: index, body: {
          settings: {
            # Allow 100_000 results per query
            index: { max_result_window: 100_000 }
          }
        }
      end

      POPULATION_TYPES.each do |type|
        puts "- Creating #{index} > #{type}"
        create_population_mapping(index, type)
      end
    end
  end

  desc "Import population from PCAxis file into ElasticSearch. Example rake population:import[2014,'db/data/population/2014.px']"
  task :import, [:year, :file_path] => :environment do |t, args|
    if m = args[:year].match(/\A\d{4}\z/)
      year = m[0].to_i
    end

    file_path = args[:file_path] || "db/data/population/#{year}.px"
    raise "Invalid year #{args[:year]}" if year.blank? || !File.file?(file_path)

    import_population(file_path, year)
  end
end
