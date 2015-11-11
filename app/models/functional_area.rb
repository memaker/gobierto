class FunctionalArea < ActiveRecord::Base
  self.table_name = "tb_cuentasProgramas"

  def self.items
    order("cdfgr")
  end

  def self.items_for_select
    items.map{ |i| ["#{'-'*i.level} #{i.code} #{i.name}", i.code] }
  end

  def self.budgets(options)
    year = options[:year]
    place = options[:place]
    code = options[:code]

    sql = <<-SQL
select sum(importe) as amount, tb_inventario.nombreente as place_name, tb_funcional.year
FROM tb_funcional
INNER join "tb_cuentasProgramas" ON "tb_cuentasProgramas".cdfgr = tb_funcional.cdfgr
INNER join tb_inventario ON tb_inventario.id = tb_funcional.id AND tb_inventario.codente = '#{place.id}AA000'
WHERE year = #{year} AND
tb_funcional.cdfgr = '#{code}'
GROUP BY tb_funcional.cdfgr, tb_inventario.nombreente, tb_funcional.year
ORDER BY amount DESC
SQL

    ActiveRecord::Base.connection.execute(sql).map do |row|
      Budget.new row
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
