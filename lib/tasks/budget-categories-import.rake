namespace :budget_categories do
  BUDGET_CATEGORIES_INDEX = 'budget-categories'
  BUDGET_CATEGORIES_TYPE = 'categories'

  def create_categories_mapping
    m = SearchEngine.client.indices.get_mapping index: BUDGET_CATEGORIES_INDEX, type: BUDGET_CATEGORIES_TYPE
    return unless m.empty?

    # document id: `<area_name>/<code>/<kind>`. Example: `economic/G`
    SearchEngine.client.indices.put_mapping index: BUDGET_CATEGORIES_INDEX, type: BUDGET_CATEGORIES_TYPE, body: {
      BUDGET_CATEGORIES_TYPE.to_sym => {
        properties: {
          area:                  { type: 'string', index: 'not_analyzed'  },
          code:                  { type: 'string', index: 'not_analyzed'  },
          name:                  { type: 'string', index: 'not_analyzed'  },
          parent_code:           { type: 'string', index: 'not_analyzed'  },
          level:                 { type: 'integer', index: 'not_analyzed' },
          kind:                  { type: 'string', index: 'not_analyzed'  } # income I / expense G
        }
      }
    }
  end

  def create_db_connection(db_name)
    ActiveRecord::Base.establish_connection ActiveRecord::Base.configurations[Rails.env].merge('database' => db_name)
    ActiveRecord::Base.connection
  end

  def import_categories(db_name)
    db = create_db_connection(db_name)

    (2010..2014).to_a.reverse.each do |year|
      import_economic_categories(db, year)
      import_functional_categories(db, year)
    end
  end

  def import_economic_categories(db, year)
    first_level_dict = {
      'G' => {"2"=>"Gastos en bienes corrientes y servicios", "3"=>"Gastos financieros", "4"=>"Transferencias corrientes", "6"=>"Inversiones reales", "7"=>"Transferencias de capital", "8"=>"Activos financieros", "9"=>"Pasivos financieros", "1"=>"Gastos de personal", "5"=>"Fondo de contingencia y otros imprevistos"},
      'I' =>  {"1"=>"Impuestos directos", "2"=>"Impuestos indirectos", "3"=>"Tasas y otros ingresos", "4"=>"Transferencias corrientes", "5"=>"Ingresos patrimoniales", "6"=>"Enajenación de inversiones reales", "7"=>"Transferencias de capital", "8"=>"Activos financieros", "9"=>"Pasivos financieros"}
    }

    table_name = "tb_cuentasEconomica_#{year}"
    sql = %Q{SELECT * from "#{table_name}"}
    db.execute(sql).each do |row|
      code = row['cdcta']
      level = code.include?('.') ? code.split('.').first.length + 1 : code.length
      parent_code = code.include?('.') ? code.split('.').first : code[0..-2]

      query = {
        area: 'economic',
        code: code,
        name: code.length == 1 ? first_level_dict[row['tipreig']][code] : row['nombre'],
        parent_code: parent_code,
        level: level,
        kind: row['tipreig']
      }

      id = ['economic',row['cdcta'],row['tipreig']].join('/')
      SearchEngine.client.index index: BUDGET_CATEGORIES_INDEX, type: BUDGET_CATEGORIES_TYPE, id: id, body: query
    end
  end

  def import_functional_categories(db, year)
    first_level_dict = {
      "3"=>"Producción de bienes públicos de carácter preferente", "0"=>"Deuda pública",
      "2"=>"Actuaciones de protección y promoción social", "9"=>"Actuaciones de carácter general",
      "4"=>"Actuaciones de carácter económico", "1"=>"Servicios públicos básicos"
    }
    table_name = "tb_cuentasProgramas_#{year}"

    sql = %Q{select * from "#{table_name}"}
    db.execute(sql).each do |row|
      code = row['cdfgr']
      level = code.include?('.') ? code.split('.').first.length + 1 : code.length
      parent_code = code.include?('.') ? code.split('.').first : code[0..-2]

      query = {
        area: 'functional',
        code: code,
        name: code.length == 1 ? first_level_dict[code] : row['nombre'],
        parent_code: parent_code,
        level: level,
        kind: 'G'
      }

      id = ['functional',row['cdfgr'],'G'].join('/')

      SearchEngine.client.index index: BUDGET_CATEGORIES_INDEX, type: BUDGET_CATEGORIES_TYPE, id: id,  body: query
    end
  end

  desc 'Reset ElasticSearch'
  task :reset => :environment do
    if SearchEngine.client.indices.exists? index: BUDGET_CATEGORIES_INDEX
      puts "- Deleting #{BUDGET_CATEGORIES_INDEX}..."
      SearchEngine.client.indices.delete index: BUDGET_CATEGORIES_INDEX
    end
  end

  desc 'Create mappings'
  task :create => :environment do
    unless SearchEngine.client.indices.exists? index: BUDGET_CATEGORIES_INDEX
      puts "- Creating index #{BUDGET_CATEGORIES_INDEX}"
      SearchEngine.client.indices.create index: BUDGET_CATEGORIES_INDEX, body: {
        settings: {
          # Allow 100_000 results per query
          index: { max_result_window: 100_000 }
        }
      }
    end

    puts "- Creating #{BUDGET_CATEGORIES_INDEX} #{BUDGET_CATEGORIES_TYPE}"
    create_categories_mapping
  end

  desc "Import categories. Example: rake budget_categories:import['db_name']"
  task :import, [:db_name] => :environment do |t, args|
    db_name = args[:db_name]
    raise "Missing db name" if db_name.blank?

    self.send("import_categories", db_name)
  end
end
