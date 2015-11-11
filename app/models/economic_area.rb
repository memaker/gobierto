class EconomicArea < ActiveRecord::Base
  self.table_name = "tb_cuentasEconomica"

  def self.items
    order("cdcta")
  end

  def self.kinds
    ['I', 'G']
  end

  def self.items_for_select
    items.map{ |i| ["#{'-'*i.level} #{i.code} #{i.name}", i.code] }
  end

  def self.budgets(options)
    year = options[:year]
    place = options[:place]
    code = options[:code]

    sql = <<-SQL
select sum(importe) as amount, tb_inventario.nombreente as place_name, tb_economica.year
FROM tb_economica
INNER join "tb_cuentasEconomica" ON "tb_cuentasEconomica".cdcta = tb_economica.cdcta
INNER join tb_inventario ON tb_inventario.id = tb_economica.id AND tb_inventario.codente = '#{place.id}AA000'
WHERE year = #{year} AND
tb_economica.cdcta = '#{code}'
GROUP BY tb_economica.cdfgr, tb_inventario.nombreente, tb_economica.year
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
    cdcta
  end

  def name
    nombre
  end


end
