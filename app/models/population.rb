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

end
