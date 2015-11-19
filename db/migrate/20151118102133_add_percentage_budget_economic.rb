class AddPercentageBudgetEconomic < ActiveRecord::Migration
  def up
    add_column :tb_economica, :percentage_total_economic, :float

    (2010..2015).each do |year|
      ['expending', 'incoming'].each do |kind|
        query_kind = kind == 'expending' ? 'G' : 'I'
        ActiveRecord::Base.connection.execute <<-SQL
  UPDATE tb_economica
  SET percentage_total_economic = (importe*100) / poblacion_municipal_2014.total_economic_#{year}_#{kind}
  FROM poblacion_municipal_2014
  WHERE tb_economica.ine_code IS NOT NULL AND poblacion_municipal_2014.codigo = tb_economica.ine_code AND year = #{year} AND tipreig = '#{query_kind}'
SQL
      end
    end
  end

  def down
    remove_column :tb_economica, :percentage_total_economic
  end
end
