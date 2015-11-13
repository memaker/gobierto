class AddLevelsToBudgetsTables < ActiveRecord::Migration
  def change
    add_column :tb_economica, :level, :integer
    add_column :tb_funcional, :level, :integer

    execute("update tb_economica set level = char_length(cdcta)")
    execute("update tb_funcional set level = char_length(cdfgr)")

    add_index :tb_economica, :level
    add_index :tb_funcional, :level
  end
end
