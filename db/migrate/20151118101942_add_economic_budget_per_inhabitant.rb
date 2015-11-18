class AddEconomicBudgetPerInhabitant < ActiveRecord::Migration
  def change
    add_column :tb_economica, :budget_per_inhabitant, :float

    execute <<-SQL
UPDATE tb_economica
SET budget_per_inhabitant = importe/poblacion_municipal_2014.total
FROM poblacion_municipal_2014
WHERE tb_economica.ine_code IS NOT NULL AND poblacion_municipal_2014.codigo = tb_economica.ine_code
SQL
  end
end
