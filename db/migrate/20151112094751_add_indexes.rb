class AddIndexes < ActiveRecord::Migration
  def change
    add_index :tb_economica, :year
    add_index :tb_economica, :cdcta
    add_index :tb_economica, :tipreig
    add_index :tb_economica, :id
    add_index :tb_funcional, :year
    add_index :tb_funcional, :cdfgr
    add_index :tb_funcional, :id
    add_index :tb_inventario, :id
    add_index :tb_inventario, :codente
  end
end
