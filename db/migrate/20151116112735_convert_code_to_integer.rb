class ConvertCodeToInteger < ActiveRecord::Migration
  def change
    execute "ALTER TABLE poblacion_municipal_2014 ALTER COLUMN codigo TYPE numeric(10,0) USING codigo::numeric"
  end
end
