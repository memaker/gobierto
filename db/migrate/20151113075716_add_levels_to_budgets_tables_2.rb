class AddLevelsToBudgetsTables2 < ActiveRecord::Migration
  def change
    add_column "tb_cuentasProgramas", :level, :integer
    add_column "tb_cuentasEconomica", :level, :integer

    execute(%Q{update "tb_cuentasProgramas" set level = char_length(cdfgr)})
    execute(%Q{update "tb_cuentasEconomica" set level = char_length(cdcta)})

    add_index "tb_cuentasProgramas", :level
    add_index "tb_cuentasEconomica", :level

  end
end
