class BudgetLine < OpenStruct
  def amount
    super.to_f
  end

  def population
    @population ||= Population.by_place_id(place_id)
  end

  def place
    @place ||= INE::Places::Place.find(place_id)
  end

  def historic_values
    sql = <<-SQL
select sum(importe) as amount
FROM tb_funcional
INNER join "tb_cuentasProgramas" ON "tb_cuentasProgramas".cdfgr = tb_funcional.cdfgr
INNER join tb_inventario ON tb_inventario.id = tb_funcional.id AND tb_inventario.codente = '#{place.id}AA000'
WHERE year IN (#{BudgetFilter.years.join(',')}) 
AND tb_funcional.cdfgr = '#{code}'
GROUP BY tb_funcional.cdfgr, tb_funcional.year
ORDER BY year ASC
    SQL

    ActiveRecord::Base.connection.execute(sql).map{|row| row['amount'] }
  end
end
