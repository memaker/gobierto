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

    conditions = ["cdcta is null"] # when cdcta is null, aggregated columns are fetched
    conditions << "year = #{year}" if year.present?

    if code.present?
      conditions << "tb_funcional.cdfgr = '#{code}'"
    else
      conditions << "tb_funcional.level = 3"
    end

    if location
      if location.is_a?(INE::Places::Place)
        conditions << "ine_code = #{location.id}"
      end
    else
      conditions << "ine_code is not null"
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

    sql = <<-SQL
select importe as amount, poblacion_municipal_2014.nombre as place_name, tb_funcional.year, ine_code as place_id,
tb_funcional.cdfgr as code, "tb_cuentasProgramas".nombre as name, poblacion_municipal_2014.total::integer as population,
poblacion_municipal_2014.total_functional_#{year} as total_functional_budget,
budget_per_inhabitant, percentage_total_functional
FROM tb_funcional
INNER join "tb_cuentasProgramas" ON "tb_cuentasProgramas".cdfgr = tb_funcional.cdfgr
INNER JOIN poblacion_municipal_2014 ON poblacion_municipal_2014.codigo = tb_funcional.ine_code #{population_filter}
WHERE #{conditions.join(' AND ')}
ORDER BY code, amount DESC
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
