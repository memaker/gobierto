class AddTbFuncionalGroupedRows < ActiveRecord::Migration
  def change
    execute <<-SQL
    INSERT INTO tb_funcional (cdfgr,cdcta,importe,year,level,ine_code)
select cdfgr, null as cdcta,sum(importe) as importe,year,level,ine_code from tb_funcional group by cdfgr,year,level,ine_code
SQL
  end
end
