class AddIndexOnPopulationTable < ActiveRecord::Migration
  def change
    add_index :poblacion_municipal_2014, :province_id
    add_index :poblacion_municipal_2014, :autonomous_region_id
    add_index :poblacion_municipal_2014, :codigo
    add_index :poblacion_municipal_2014, :total
  end
end
