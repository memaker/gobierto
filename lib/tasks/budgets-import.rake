namespace :budgets do
  BUDGETS_INDEXES = [SearchEngineConfiguration::BudgetLine.index_forecast, SearchEngineConfiguration::BudgetLine.index_executed]
  BUDGETS_TYPES = ['economic', 'functional']

  def create_budgets_mapping(index, type)
    m = SearchEngine.client.indices.get_mapping index: index, type: type
    return unless m.empty?

    # BUDGETS_INDEX: budgets-forecast // budgets-execution
    # BUDGETS_TYPE: economic // functional
    #
    # Document identifier: <ine_code>/<year>/<code>/<kind>
    #
    # Example: 28079/2015/210.00/0
    # Example: 28079/2015/210.00/1
    SearchEngine.client.indices.put_mapping index: index, type: type, body: {
      type.to_sym => {
        properties: {
          ine_code:              { type: 'integer', index: 'not_analyzed' },
          year:                  { type: 'integer', index: 'not_analyzed' },
          amount:                { type: 'double', index: 'not_analyzed'  },
          code:                  { type: 'string', index: 'not_analyzed'  },
          parent_code:           { type: 'string', index: 'not_analyzed'  },
          level:                 { type: 'integer', index: 'not_analyzed' },
          kind:                  { type: 'string', index: 'not_analyzed'  }, # income I / expense G
          province_id:           { type: 'integer', index: 'not_analyzed' },
          autonomy_id:           { type: 'integer', index: 'not_analyzed' },
          amount_per_inhabitant: { type: 'double', index: 'not_analyzed'  }
        }
      }
    }
  end

  def create_db_connection(db_name)
    ActiveRecord::Base.establish_connection ActiveRecord::Base.configurations[Rails.env].merge('database' => db_name)
    ActiveRecord::Base.connection
  end

  def population(id, year)
    response = SearchEngine.client.get index: 'data', type: 'population', id: "#{id}/#{year}"
    response['_source']['value']
  rescue
    nil
  end

  def import_functional_budgets(db_name, index, year)
    db = create_db_connection(db_name)

    pbar = ProgressBar.new("functional-#{year}", INE::Places::Place.all.length)

    INE::Places::Place.all.each do |place|
      pbar.inc
      pop = population(place.id, year)
      next if pop.nil?

      base_data = {
        ine_code: place.id.to_i, province_id: place.province.id.to_i,
        autonomy_id: place.province.autonomous_region.id.to_i, year: year,
        population: pop
      }

      sql = <<-SQL
SELECT tb_funcional_#{year}.cdfgr as code, sum(tb_funcional_#{year}.importe) as amount
FROM tb_funcional_#{year}
INNER JOIN "tb_inventario_#{year}" ON tb_inventario_#{year}.idente = tb_funcional_#{year}.idente AND tb_inventario_#{year}.codente = '#{format("%.5i", place.id)}AA000'
GROUP BY tb_funcional_#{year}.cdfgr
SQL

      index_request_body = []
      db.execute(sql).each do |row|
        data = base_data.merge({
          amount: row['amount'].to_f.round(2), code: row['code'],
          level: row['code'].length, kind: 'G',
          amount_per_inhabitant: (row['amount'].to_f / pop).round(2),
          parent_code: row['code'][0..-2]
        })

        id = [place.id,year,row['code'],'G'].join("/")
        index_request_body << {index: {_id: id, data: data}}
      end
      next if index_request_body.empty?

      SearchEngine.client.bulk index: index, type: 'functional', body: index_request_body
    end

    pbar.finish
  end

  def import_economic_budgets(db_name, index, year)
    db = create_db_connection(db_name)

    pbar = ProgressBar.new("economic-#{year}", INE::Places::Place.all.length)

    INE::Places::Place.all.each do |place|
      pbar.inc
      pop = population(place.id, year)
      next if pop.nil?

      base_data = {
        ine_code: place.id.to_i, province_id: place.province.id.to_i,
        autonomy_id: place.province.autonomous_region.id.to_i, year: year,
        population: pop
      }

      amount_column = if index == SearchEngineConfiguration::BudgetLine.index_forecast
                        'importe'
                      elsif index == SearchEngineConfiguration::BudgetLine.index_executed
                        'importer'
                      end

      sql = <<-SQL
SELECT tb_economica_#{year}.cdcta as code, tb_economica_#{year}.tipreig AS kind, tb_economica_#{year}.#{amount_column} as amount
FROM tb_economica_#{year}
INNER JOIN "tb_inventario_#{year}" ON tb_inventario_#{year}.idente = tb_economica_#{year}.idente AND tb_inventario_#{year}.codente = '#{format("%.5i", place.id)}AA000'
SQL

      index_request_body = []
      db.execute(sql).each do |row|
        data = base_data.merge({
          amount: row['amount'].to_f.round(2), code: row['code'],
          level: row['code'].length, kind: row['kind'],
          amount_per_inhabitant: (row['amount'].to_f / pop).round(2),
          parent_code: row['code'][0..-2]
        })

        id = [place.id,year,row['code'],row['kind']].join("/")
        index_request_body << {index: {_id: id, data: data}}
      end
      next if index_request_body.empty?

      SearchEngine.client.bulk index: index, type: 'economic', body: index_request_body
    end

    pbar.finish
  end

  desc 'Reset ElasticSearch'
  task :reset => :environment do
    BUDGETS_INDEXES.each do |index|
      if SearchEngine.client.indices.exists? index: index
        puts "- Deleting #{index}..."
        SearchEngine.client.indices.delete index: index
      end
    end
  end

  desc 'Create mappings'
  task :create => :environment do
    BUDGETS_INDEXES.each do |index|
      unless SearchEngine.client.indices.exists? index: index
        puts "- Creating index #{index}"
        SearchEngine.client.indices.create index: index, body: {
          settings: {
            # Allow 100_000 results per query
            index: { max_result_window: 100_000 }
          }
        }
      end

      BUDGETS_TYPES.each do |type|
        puts "- Creating #{index} #{type}"
        create_budgets_mapping(index, type)
      end
    end
  end

  desc "Import budgets from database into ElasticSearch. Example rake budgets:import['budgets-dbname','budgets-execution','economic',2015]"
  task :import, [:db_name, :index,:type,:year] => :environment do |t, args|
    db_name = args[:db_name]
    index = args[:index] if BUDGETS_INDEXES.include?(args[:index])
    raise "Invalid index #{args[:index]}" if index.blank?
    type = args[:type] if BUDGETS_TYPES.include?(args[:type])
    raise "Invalid type #{args[:type]}" if type.blank?

    if m = args[:year].match(/\A\d{4}\z/)
      year = m[0].to_i
    end
    raise "Invalid year #{args[:year]}" if year.blank?

    self.send("import_#{type}_budgets", db_name, index, year)
  end
end
