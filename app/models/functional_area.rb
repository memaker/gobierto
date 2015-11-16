class FunctionalArea < ActiveRecord::Base
  self.table_name = "tb_cuentasProgramas"

  def self.items
    order("cdfgr")
  end

  def self.root_items
    where("level = 1").order("cdfgr")
  end

  def children
    self.class.items.where("cdfgr like '#{self.code}%' AND level = #{self.level + 2}")
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

    sql = <<-SQL
select importe as amount, poblacion_municipal_2014.nombre as place_name, tb_funcional.year, tb_funcional.ine_code as place_id,
tb_funcional.cdfgr as code, "tb_cuentasProgramas".nombre as name, poblacion_municipal_2014.total::integer as population,
poblacion_municipal_2014.total_functional_#{year} as total_functional_budget, 
budget_per_inhabitant, percentage_total_functional,
total_2010, total_2011, total_2012, total_2013, total_2014, total_2015
FROM tb_funcional
INNER join "tb_cuentasProgramas" ON "tb_cuentasProgramas".cdfgr = tb_funcional.cdfgr
INNER JOIN poblacion_municipal_2014 ON poblacion_municipal_2014.codigo = tb_funcional.ine_code #{population_filter}
INNER JOIN functional_yearly_totals ON tb_funcional.cdfgr = functional_yearly_totals.cdfgr AND tb_funcional.ine_code = functional_yearly_totals.ine_code
WHERE #{conditions.join(' AND ')}
ORDER BY importe DESC
#{"LIMIT 300" if location.nil?}
SQL

    ActiveRecord::Base.connection.execute(sql).map do |row|
      BudgetLine.new row
    end
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
select sum(importe) as amount
FROM tb_funcional
INNER join tb_inventario ON tb_inventario.id = tb_funcional.id AND tb_inventario.codente = '#{place.id}AA000'
WHERE year = #{year} AND level = 1 AND tb_funcional.cdfgr = '#{self.code}'
SQL

    ActiveRecord::Base.connection.execute(sql).first['amount'].to_f
  end

  def budget_per_person(place, year)
    total = budget(place, year)

    total / Population.by_place_id(place.id).total
  end

  def budget_percentage_total(place, year, total)
    part = budget(place, year)
    if total > 0
      (part.to_f * 100.0)/total.to_f
    else
      0
    end
  end

  def mean_national_per_person(year)
     sql = <<-SQL
select avg(x)
FROM(
  select sum(importe)/total as x
  FROM tb_funcional
  INNER join tb_inventario ON tb_inventario.id = tb_funcional.id
  INNER JOIN poblacion_municipal_2014 ON poblacion_municipal_2014.codigo = substring(tb_inventario.codente from 0 for 6)
  WHERE year = #{year} AND level = 1 AND tb_funcional.cdfgr = '#{self.code}'
  GROUP BY tb_inventario.id, poblacion_municipal_2014.total
)  as mean
SQL

    ActiveRecord::Base.connection.execute(sql).first['avg'].to_f
  end

  def mean_autonomy_per_person(year, place)
    0
  end

  def mean_province_per_person(year, place)
    0
  end

  def mean_national_percentage(year, total)
     sql = <<-SQL
select avg(x)
FROM(
  select 
    (
      select sum(importe)
      FROM tb_funcional
      INNER join tb_inventario ON tb_inventario.id = tb_funcional.id
      WHERE year = #{year} AND level = 1
    ) as total, 
    (sum(importe)::double precision/total::double precision) * 100 as x
  FROM tb_funcional
  INNER join tb_inventario ON tb_inventario.id = tb_funcional.id
  WHERE year = #{year} AND level = 1 AND tb_funcional.cdfgr = '#{self.code}'
  GROUP BY tb_inventario.id
)  as mean
SQL

    ActiveRecord::Base.connection.execute(sql).first['avg'].to_f
  end

  def mean_autonomy_percentage(year, place, total)
    0
  end

  def mean_province_percentage(year, place, total)
    0
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
