class AddBudgetPerInhabitantFunctional < ActiveRecord::Migration
  def change
    add_column :tb_funcional, :budget_per_inhabitant, :float

    execute <<-SQL
UPDATE tb_funcional
SET budget_per_inhabitant = importe/poblacion_municipal_2014.total
FROM poblacion_municipal_2014
WHERE tb_funcional.ine_code IS NOT NULL AND poblacion_municipal_2014.codigo = tb_funcional.ine_code
SQL
  end
end
