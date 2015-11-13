class FixPopulationCodes < ActiveRecord::Migration
  def change
    execute("update poblacion_municipal_2014 set codigo = '0' || codigo where char_length(codigo) = 4")
  end
end
