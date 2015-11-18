class AddIndexOnCdcta < ActiveRecord::Migration
  def change
    add_index :tb_funcional, :cdcta
  end
end
