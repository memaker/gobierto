class AddTbPercentageTotalFunctional < ActiveRecord::Migration
  def up
    add_column :tb_funcional, :percentage_total_functional, :float

    (2010..2015).each do |year|
      execute <<-SQL
  UPDATE tb_funcional
  SET percentage_total_functional = (importe*100) / poblacion_municipal_2014.total_functional_#{year}
  FROM poblacion_municipal_2014
  WHERE tb_funcional.ine_code IS NOT NULL AND tb_funcional.cdcta IS NULL AND
    poblacion_municipal_2014.codigo = tb_funcional.ine_code AND year = #{year}
SQL
    end
  end

  def down
    remove_column :tb_funcional, :percentage_total_functional
  end
end
