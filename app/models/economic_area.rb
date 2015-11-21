class EconomicArea < ActiveRecord::Base
  EXPENDING = 'G'
  INCOME    = 'I'

  self.table_name = "tb_cuentasEconomica"

  def self.items
    order("cdcta")
  end

  def self.root_items(kind)
    where(level: 1, tipreig: kind).order("cdcta")
  end

  def self.categories_count(level, kind)
    where(level: level + 1, tipreig: kind).count
  end

  def self.find(code, kind)
    find_by(cdcta: code, tipreig: kind)
  end

  def children
    self.class.items.where("cdcta like '#{self.code}%' AND level = #{self.level + 2} AND tipreig = '#{self.tipreig}'")
  end

  def parents
    if self.level == 0
      []
    else
      parents = []
      category = self

      while(category.level >= 1)
        code = category.code[0..-2]
        category = self.class.find(code, self.tipreig)
        parents.push category
      end

      return parents.reverse
    end
  end

  def self.kinds
    [['Gastos', EXPENDING], ['Ingresos', INCOME]]
  end

  def self.items_for_select
    items.map{ |i| ["#{'-'*i.level} #{i.code} #{i.name}", i.code] }
  end

  def self.budgets(options)
    year = options[:year]
    location = options[:location]
    code = options[:code]
    kind = options[:kind]
    kind_sql = options[:kind] == 'G' ? 'expending' : 'incoming'
    population = options[:population]
    similar_budget = options[:similar_budget]
    total_similar_budget = options[:total_similar_budget]
    pagination = options[:pagination]
    sort_by = options[:sort_by]

    conditions = ["tb_economica.tipreig = '#{options[:kind]}'"]
    conditions << "idente is null" # when id is null we are fetching the aggregated data

    conditions << "year = #{year}" if year.present?

    if code.present?
      conditions << "tb_economica.cdcta = '#{code}'"
    else
      conditions << "tb_economica.level = 3"
    end

    if location
      if location.is_a?(INE::Places::Place)
        conditions << "tb_economica.ine_code = #{location.id}"
      end
    else
      conditions << "tb_economica.ine_code is not null"
    end

    population_filter = []
    if population.any?
      population_limits = ["total >= #{population.first}"]
      population_limits << "total <= #{population.last}" if population.last > 0

      population_filter << "#{population_limits.join(' AND ')}"
    end

    if location
      if location.is_a?(INE::Places::Province)
        population_filter << "poblacion_municipal_2014.province_id = #{location.id}"
      elsif location.is_a?(INE::Places::AutonomousRegion)
        population_filter << "poblacion_municipal_2014.autonomous_region_id = #{location.id}"
      end
    end

    if population_filter.any?
      population_filter = " AND #{population_filter.join(' AND ')}"
    else
      population_filter = nil
    end

    if similar_budget.any?
      conditions << "importe > #{similar_budget.first}"
      conditions << "importe < #{similar_budget.last}"
    end

    if total_similar_budget.any?
      conditions << "poblacion_municipal_2014.total_economic_#{year}_#{kind_sql} > #{total_similar_budget.first}"
      conditions << "poblacion_municipal_2014.total_economic_#{year}_#{kind_sql} < #{total_similar_budget.last}"
    end

    count_sql = <<-SQL
select count(*) as count FROM tb_economica
INNER JOIN poblacion_municipal_2014 ON poblacion_municipal_2014.codigo = tb_economica.ine_code #{population_filter}
WHERE #{conditions.join(' AND ')}
SQL

    total_records = ActiveRecord::Base.connection.execute(count_sql).first['count'].to_i

    sql = <<-SQL
select importe as budget, poblacion_municipal_2014.nombre as place_name, tb_economica.year, tb_economica.ine_code as place_id,
tb_economica.cdcta as code, "tb_cuentasEconomica".nombre as name, poblacion_municipal_2014.total::integer as population,
poblacion_municipal_2014.total_economic_#{year}_#{kind_sql} as total_economic_budget, 
budget_per_inhabitant, percentage_total_economic as percentage_from_total,
total_2010, total_2011, total_2012, total_2013, total_2014, total_2015
FROM tb_economica
INNER join "tb_cuentasEconomica" ON "tb_cuentasEconomica".cdcta = tb_economica.cdcta AND "tb_cuentasEconomica".tipreig = '#{options[:kind]}'
INNER JOIN poblacion_municipal_2014 ON poblacion_municipal_2014.codigo = tb_economica.ine_code #{population_filter}
INNER JOIN economic_yearly_totals ON tb_economica.ine_code = economic_yearly_totals.ine_code AND tb_economica.cdcta = economic_yearly_totals.cdcta AND tb_economica.tipreig = economic_yearly_totals.kind
WHERE #{conditions.join(' AND ')}
ORDER BY #{sort_by[:attribute]} #{sort_by[:direction]}
LIMIT #{pagination[:per_page]}
OFFSET #{pagination[:offset]}
SQL

    PaginatedResult.new total_records, ActiveRecord::Base.connection.execute(sql).map { |row| BudgetLine.new(row) }
  end

  def self.total_budget(kind, place_id, year)
    sql = <<-SQL
select sum(importe) as amount
FROM tb_economica
WHERE year = #{year} AND tb_economica.level = 1 AND ine_code = #{place_id} AND idente is null 
AND tipreig = '#{kind}'
SQL

    row = ActiveRecord::Base.connection.execute(sql).first
    if row.nil?
      0
    else
      return row['amount'].to_f
    end
  end

  def budget(place, year)
    conditions = []
    conditions << "ine_code = #{place.id}"
    conditions << "year = #{year}"
    conditions << "level = 1"
    conditions << "tb_economica.cdcta = '#{self.code}'"
    conditions << "idente is null"
    conditions << "tipreig = '#{self.tipreig}'"

    sql = <<-SQL
select importe as amount, budget_per_inhabitant, percentage_total_economic
FROM tb_economica
WHERE #{conditions.join(' AND ')}
    SQL

    ActiveRecord::Base.connection.execute(sql).first
  end

  def budget_per_person(place, year)
    if r = budget(place, year)
      r['budget_per_inhabitant'].to_f
    else
      0
    end
  end

  def budget_percentage_total(place, year, total)
    if r = budget(place, year)
      r['percentage_total_economic'].to_f
    else
      0
    end
  end

  def budget_national_total(year)
    Rails.cache.fetch("economic/sum_national/#{kind}/#{self.code}/#{year}") do
       sql = <<-SQL
 select sum(importe) as total
 from tb_economica
 where tipreig='#{kind}' and year=#{year} and cdcta='#{code}' and idente is null
  SQL

      ActiveRecord::Base.connection.execute(sql).first['total'].to_f
    end
  end

  def mean_national_per_person(year)
    Rails.cache.fetch("economic/national/#{kind}/#{self.code}/#{year}") do
       sql = <<-SQL
select avg(x)
FROM(
  select budget_per_inhabitant as x
  FROM tb_economica
  WHERE year = #{year} AND tb_economica.cdcta = '#{self.code}' AND idente is null AND  tipreig = '#{kind}'
)  as mean
SQL

      ActiveRecord::Base.connection.execute(sql).first['avg'].to_f
    end
  end

  def mean_autonomy_per_person(year, place)
    Rails.cache.fetch("economic/autonomous_region/#{place.province.autonomous_region.id}/#{kind}/#{self.code}/#{year}") do
      sql = <<-SQL
select avg(x)
FROM(
  select budget_per_inhabitant as x
  FROM tb_economica
  INNER JOIN poblacion_municipal_2014 ON poblacion_municipal_2014.codigo = tb_economica.ine_code AND poblacion_municipal_2014.autonomous_region_id = #{place.province.autonomous_region.id}
  WHERE year = #{year} AND tb_economica.cdcta = '#{self.code}' AND idente is null AND  tipreig = '#{kind}'
)  as mean
  SQL
      ActiveRecord::Base.connection.execute(sql).first['avg'].to_f
    end
  end

  def mean_province_per_person(year, place)
    Rails.cache.fetch("economic/province/#{place.province.id}/#{kind}/#{self.code}/#{year}") do
     sql = <<-SQL
select avg(x)
FROM(
  select budget_per_inhabitant as x
  FROM tb_economica
  INNER JOIN poblacion_municipal_2014 ON poblacion_municipal_2014.codigo = tb_economica.ine_code AND poblacion_municipal_2014.province_id = #{place.province.id}
  WHERE year = #{year} AND tb_economica.cdcta = '#{self.code}' AND idente is null AND  tipreig = '#{kind}'
)  as mean
SQL
      ActiveRecord::Base.connection.execute(sql).first['avg'].to_f
    end
  end

  def national_ranking(year)
    query = "select sum(total_#{year}) as sum,cdcta FROM economic_yearly_totals where kind='#{self.kind}' AND char_length(cdcta) = #{self.level + 1} GROUP BY cdcta ORDER BY sum DESC"

    ActiveRecord::Base.connection.execute(query).map{|r| r['cdcta'] }.index(self.code) + 1
  end

  def level
    code.length - 1
  end

  def code
    cdcta
  end

  def name
    nombre
  end

  def kind
    tipreig
  end

  def smaller_budgets_per_inhabitant(year)
    sql = <<-SQL
  select ine_code as place_id,budget_per_inhabitant as amount
  FROM tb_economica
  WHERE year = #{year} AND tb_economica.cdcta = '#{self.code}' AND idente is null AND tipreig = '#{kind}' AND ine_code is not null AND budget_per_inhabitant is not null
  ORDER BY budget_per_inhabitant ASC
  LIMIT 5
SQL
    ActiveRecord::Base.connection.execute(sql).map do |row|
      BudgetLine.new row
    end
  end

  def bigger_budgets_per_inhabitant(year)
    sql = <<-SQL
  select ine_code as place_id,budget_per_inhabitant as amount
  FROM tb_economica
  WHERE year = #{year} AND tb_economica.cdcta = '#{self.code}' AND idente is null AND tipreig = '#{kind}' AND ine_code is not null AND budget_per_inhabitant is not null
  ORDER BY budget_per_inhabitant DESC
  LIMIT 5
SQL
    ActiveRecord::Base.connection.execute(sql).map do |row|
      BudgetLine.new row
    end
  end
end
