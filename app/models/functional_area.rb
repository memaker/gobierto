class FunctionalArea < ActiveRecord::Base
  self.table_name = "tb_cuentasProgramas"

  def self.items
    order("cdfgr")
  end

  def self.root_items
    where("level = 1").order("cdfgr")
  end

  def self.find(code)
    find_by(cdfgr: code)
  end

  def children
    self.class.items.where("cdfgr like '#{self.code}%' AND level = #{self.level + 2}")
  end

  def parents
    if self.level == 1
      []
    else
      parents = []
      category = self

      while(category.level >= 1)
        code = category.code[0..-2]
        category = self.class.find(code)
        parents.push category
      end

      return parents
    end
  end

  def self.items_for_select
    items.map{ |i| ["#{'-'*i.level} #{i.code} #{i.name}", i.code] }
  end

  def self.budgets(options)
    year = options[:year]
    location = options[:location]
    code = options[:code]
    population = options[:population]
    similar_budget = options[:similar_budget]
    total_similar_budget = options[:total_similar_budget]
    pagination = options[:pagination]
    sort_by = options[:sort_by]

    conditions = ["cdcta is null"] # when cdcta is null, aggregated columns are fetched
    conditions << "year = #{year}" if year.present?

    if code.present?
      conditions << "tb_funcional.cdfgr = '#{code}'"
    else
      conditions << "tb_funcional.level = 3"
    end

    if location
      if location.is_a?(INE::Places::Place)
        conditions << "tb_funcional.ine_code = #{location.id}"
      end
    else
      conditions << "tb_funcional.ine_code is not null"
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
      conditions << "poblacion_municipal_2014.total_functional_#{year} > #{total_similar_budget.first}"
      conditions << "poblacion_municipal_2014.total_functional_#{year} < #{total_similar_budget.last}"
    end

    count_sql = <<-SQL
select count(*) as count FROM tb_funcional
INNER JOIN poblacion_municipal_2014 ON poblacion_municipal_2014.codigo = tb_funcional.ine_code #{population_filter}
WHERE #{conditions.join(' AND ')}
SQL

    total_records = ActiveRecord::Base.connection.execute(count_sql).first['count'].to_i

    sql = <<-SQL
select importe as budget, poblacion_municipal_2014.nombre as place_name, tb_funcional.year, tb_funcional.ine_code as place_id,
tb_funcional.cdfgr as code, "tb_cuentasProgramas".nombre as name, poblacion_municipal_2014.total::integer as population,
poblacion_municipal_2014.total_functional_#{year} as total_functional_budget, 
budget_per_inhabitant, percentage_total_functional as percentage_from_total,
total_2010, total_2011, total_2012, total_2013, total_2014, total_2015
FROM tb_funcional
INNER join "tb_cuentasProgramas" ON "tb_cuentasProgramas".cdfgr = tb_funcional.cdfgr
INNER JOIN poblacion_municipal_2014 ON poblacion_municipal_2014.codigo = tb_funcional.ine_code #{population_filter}
INNER JOIN functional_yearly_totals ON tb_funcional.cdfgr = functional_yearly_totals.cdfgr AND tb_funcional.ine_code = functional_yearly_totals.ine_code
WHERE #{conditions.join(' AND ')}
ORDER BY #{sort_by[:attribute]} #{sort_by[:direction]}
LIMIT #{pagination[:per_page]}
OFFSET #{pagination[:offset]}
SQL

    PaginatedResult.new total_records, ActiveRecord::Base.connection.execute(sql).map { |row| BudgetLine.new(row) }
  end

  def self.total_budget(place_id, year)
    sql = <<-SQL
select sum(importe) as amount
FROM tb_funcional
WHERE year = #{year} AND level = 1 AND ine_code = #{place_id}
SQL

    ActiveRecord::Base.connection.execute(sql).first['amount'].to_f
  end

  def budget(place, year)
    sql = <<-SQL
select importe as amount, budget_per_inhabitant, percentage_total_functional
FROM tb_funcional
WHERE ine_code = #{place.id} AND year = #{year} AND level = 1 AND tb_funcional.cdfgr = '#{self.code}' AND cdcta is null
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
      r['percentage_total_functional'].to_f
    else
      0
    end
  end

  def mean_national_per_person(year)
    Rails.cache.fetch("functional/national/#{self.code}/#{year}") do
       sql = <<-SQL
  select avg(x)
  FROM(
    select budget_per_inhabitant as x
    FROM tb_funcional
    WHERE year = #{year} AND level = 1 AND tb_funcional.cdfgr = '#{self.code}' AND cdcta is null
  )  as mean
  SQL

      ActiveRecord::Base.connection.execute(sql).first['avg'].to_f
    end
  end

  def mean_autonomy_per_person(year, place)
    Rails.cache.fetch("functional/autonomous_region/#{place.province.autonomous_region.id}/#{self.code}/#{year}") do
      sql = <<-SQL
select avg(x)
FROM(
  select budget_per_inhabitant as x
  FROM tb_funcional
  INNER JOIN poblacion_municipal_2014 ON poblacion_municipal_2014.codigo = tb_funcional.ine_code AND poblacion_municipal_2014.autonomous_region_id = #{place.province.autonomous_region.id}
  WHERE year = #{year} AND level = 1 AND tb_funcional.cdfgr = '#{self.code}' AND cdcta is null
)  as mean
  SQL
      ActiveRecord::Base.connection.execute(sql).first['avg'].to_f
    end
  end

  def mean_province_per_person(year, place)
    Rails.cache.fetch("functional/province/#{place.province.id}/#{self.code}/#{year}") do
     sql = <<-SQL
select avg(x)
FROM(
  select budget_per_inhabitant as x
  FROM tb_funcional
  INNER JOIN poblacion_municipal_2014 ON poblacion_municipal_2014.codigo = tb_funcional.ine_code AND poblacion_municipal_2014.province_id = #{place.province.id}
  WHERE year = #{year} AND level = 1 AND tb_funcional.cdfgr = '#{self.code}' AND cdcta is null
)  as mean
SQL
      ActiveRecord::Base.connection.execute(sql).first['avg'].to_f
    end
  end

  def level
    code.length - 1
  end

  def code
    cdfgr
  end

  def name
    nombre
  end

end
