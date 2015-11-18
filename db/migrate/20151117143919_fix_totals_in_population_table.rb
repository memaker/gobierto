class FixTotalsInPopulationTable < ActiveRecord::Migration
  def change
    execute "DELETE FROM poblacion_municipal_2014 WHERE codigo = 1"
  end
end
