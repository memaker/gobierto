class AddIndexesToIneCodes < ActiveRecord::Migration
  def change
    add_index :tb_funcional, :ine_code
    add_index :tb_economica, :ine_code
  end
end
