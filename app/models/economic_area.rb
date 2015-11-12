class EconomicArea < ActiveRecord::Base
  self.table_name = "tb_cuentasEconomica"

  def self.items
    order("cdcta")
  end

  def self.kinds
    [['Gastos','G'],['Ingresos','I']]
  end

  def self.items_for_select
    items.map{ |i| ["#{'-'*i.level} #{i.code} #{i.name}", i.code] }
  end

  def self.budgets(options)
    year = options[:year]
    place = options[:place]
    code = options[:code]

    sql = <<-SQL
select sum(importe) as amount, tb_inventario.nombreente as place_name, tb_economica.year, #{place.id} as place_id
FROM tb_economica
INNER join "tb_cuentasEconomica" ON "tb_cuentasEconomica".cdcta = tb_economica.cdcta
INNER join tb_inventario ON tb_inventario.id = tb_economica.id AND tb_inventario.codente = '#{place.id}AA000'
WHERE year = #{year} AND
tb_economica.cdcta = '#{code}'
GROUP BY tb_economica.cdcta, tb_inventario.nombreente, tb_economica.year
ORDER BY amount DESC
SQL

    ActiveRecord::Base.connection.execute(sql).map do |row|
      BudgetLine.new row
    end
  end

  def self.total_budget(place_id, year)
    sql = <<-SQL
select sum(importe) as amount
FROM tb_economica
INNER join tb_inventario ON tb_inventario.id = tb_economica.id AND tb_inventario.codente = '#{place_id}AA000'
WHERE year = #{year} AND
char_length(tb_economica.cdcta) = 1
SQL

    ActiveRecord::Base.connection.execute(sql).first['amount'].to_f
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


end
