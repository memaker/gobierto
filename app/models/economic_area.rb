class EconomicArea < ActiveRecord::Base
  self.table_name = "tb_cuentasEconomica"

  def self.items
    order("cdcta")
  end

  def self.root_items
    where("level = 1").order("cdcta")
  end

  def children
    self.class.items.where("cdcta like '#{self.code}%' AND level = #{self.level + 2}")
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
select sum(importe) as amount, tb_inventario.nombreente as place_name, tb_economica.year, ine_code as place_id
FROM tb_economica
INNER join "tb_cuentasEconomica" ON "tb_cuentasEconomica".cdcta = tb_economica.cdcta
WHERE year = #{year} AND tb_economica.cdcta = '#{code}' AND ine_code = #{place.id}
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
WHERE year = #{year} AND tb_economica.level = 1 AND ine_code = #{place.id}
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
