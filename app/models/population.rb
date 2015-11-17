class Population < ActiveRecord::Base
  self.table_name = 'poblacion_municipal_2014'
  self.primary_key = 'codigo'

  def place
    @place ||= INE::Places::Place.find(self.codigo)
  end

  def ranking(year, code = nil)
    query = if code.nil?
      "select codigo as ine_code,rank() OVER (ORDER BY total_functional_#{year} DESC) FROM poblacion_municipal_2014"
    else
      "select ine_code,rank() OVER (ORDER BY importe DESC) FROM tb_funcional WHERE (cdcta IS NULL AND year = #{year} AND cdfgr = '#{code}')"
    end

    ActiveRecord::Base.connection.execute(query).detect{|r| r['ine_code'].to_i == self.codigo }['rank'].to_i
  end

  def bigger_functional_budgets(year)
    sql = <<-SQL
select importe as amount, "tb_cuentasProgramas".nombre as name
FROM tb_funcional
INNER join "tb_cuentasProgramas" ON "tb_cuentasProgramas".cdfgr = tb_funcional.cdfgr
INNER JOIN poblacion_municipal_2014 ON poblacion_municipal_2014.codigo = tb_funcional.ine_code
WHERE cdcta is null and ine_code = #{self.codigo} AND year = #{year}
AND tb_funcional.level = 3
ORDER BY importe DESC
LIMIT 5
SQL

    ActiveRecord::Base.connection.execute(sql).map do |row|
      BudgetLine.new row
    end
  end

  def smaller_functional_budgets(year)
    sql = <<-SQL
select importe as amount, "tb_cuentasProgramas".nombre as name
FROM tb_funcional
INNER join "tb_cuentasProgramas" ON "tb_cuentasProgramas".cdfgr = tb_funcional.cdfgr
INNER JOIN poblacion_municipal_2014 ON poblacion_municipal_2014.codigo = tb_funcional.ine_code
WHERE cdcta is null and ine_code = #{self.codigo} AND year = #{year}
AND tb_funcional.level = 3
ORDER BY importe ASC
LIMIT 5
SQL

    ActiveRecord::Base.connection.execute(sql).map do |row|
      BudgetLine.new row
    end

  end
end
