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
    place = options[:place]
    code = options[:code]
    population = options[:population]

    place_conditions = if place
                         "AND tb_inventario.codente = '#{format('%.5i', place.id)}AA000'"
                       else
                         "AND tb_inventario.codente like '%AA000'"
                       end

    conditions = []
    conditions << "year = #{year}" if year.present?

    if code.present?
      conditions << "tb_funcional.cdfgr = '#{code}'"
    else
      conditions << "tb_funcional.level = 3"
    end

    population_filter = if population.present?
                          population_limits = ["total >= #{population.first}"]
                          population_limits << "total <= #{population.last}" if population.last > 0
                          "INNER JOIN poblacion_municipal_2014 ON poblacion_municipal_2014.codigo = substring(tb_inventario.codente from 0 for 6) AND #{population_limits.join(' AND ')}"
                        end

    sql = <<-SQL
select sum(importe) as amount, tb_inventario.nombreente as place_name, tb_funcional.year, substring(tb_inventario.codente from 0 for 6) as place_id,
tb_funcional.cdfgr as code, "tb_cuentasProgramas".nombre as name
FROM tb_funcional
INNER join "tb_cuentasProgramas" ON "tb_cuentasProgramas".cdfgr = tb_funcional.cdfgr
INNER join tb_inventario ON tb_inventario.id = tb_funcional.id #{place_conditions}
#{population_filter}
WHERE #{conditions.join(' AND ')}
GROUP BY tb_funcional.cdfgr, tb_inventario.nombreente, tb_funcional.year, "tb_cuentasProgramas".nombre, tb_inventario.codente
ORDER BY code, amount DESC
#{"LIMIT 300" if place.nil?}
SQL

    ActiveRecord::Base.connection.execute(sql).map do |row|
      BudgetLine.new row
    end
  end

  def self.total_budget(place_id, year)
    sql = <<-SQL
select sum(importe) as amount
FROM tb_funcional
INNER join tb_inventario ON tb_inventario.id = tb_funcional.id AND tb_inventario.codente = '#{place_id}AA000'
WHERE year = #{year} AND level = 1
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
