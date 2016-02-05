namespace :places do
  PLACES_INDEXES = ['data']
  PLACES_TYPES = ['places']

  def create_mapping(index, type)
    m = SearchEngine.client.indices.get_mapping index: index, type: type
    return unless m.empty?

    # Document identifier: <ine_code>
    #
    # Example: 28079
    SearchEngine.client.indices.put_mapping index: index, type: type, body: {
      type.to_sym => {
        properties: {
          ine_code:              { type: 'integer', index: 'not_analyzed' },
          province_id:           { type: 'integer', index: 'not_analyzed' },
          autonomy_id:           { type: 'integer', index: 'not_analyzed' },
          year:                  { type: 'integer', index: 'not_analyzed' },
          name:                  { type: 'string',  index: 'analyzed' }
        }
      }
    }
  end

  def import_places
    pbar = ProgressBar.new("places", INE::Places::Place.all.length)

    INE::Places::Place.all.each do |place|
      pbar.inc
      place_name = if place.name.include?(',')
                     place.name.split(',').map{|i| i.strip}.reverse.join(' ')
                   else
                     place.name
                   end
      data = {
        ine_code: place.id.to_i, province_id: place.province.id.to_i,
        autonomy_id: place.province.autonomous_region.id.to_i, year: 2015,
        name: place_name
      }

      id = place.id

      SearchEngine.client.index index: PLACES_INDEXES.first, type: PLACES_TYPES.first, id: id, body: data
    end

    pbar.finish
  end

  desc 'Reset ElasticSearch'
  task :reset => :environment do
    PLACES_INDEXES.each do |index|
      if SearchEngine.client.indices.exists? index: index
        puts "- Deleting #{index} index"
        SearchEngine.client.indices.delete index: index
      end
    end
  end

  desc 'Create mappings'
  task :create => :environment do
    PLACES_INDEXES.each do |index|
      unless SearchEngine.client.indices.exists? index: index
        puts "- Creating index #{index}"
        SearchEngine.client.indices.create index: index, body: {
          settings: {
            # Allow 100_000 results per query
            index: { max_result_window: 100_000 }
          }
        }
      end

      PLACES_TYPES.each do |type|
        puts "- Creating #{index} > #{type}"
        create_mapping(index, type)
      end
    end
  end

  desc "Import places from INEPlaces gem file into ElasticSearch. Example rake places:import"
  task :import => :environment do
    import_places
  end
end
