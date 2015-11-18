class AddGroupedTablesEconomic < ActiveRecord::Migration
  def up
    # select count(*) from tb_economica where id is null;
    execute <<-SQL
    INSERT INTO tb_economica (cdcta,importe,year,level,ine_code,tipreig)
select cdcta,sum(importe),year,level,ine_code,tipreig from tb_economica
group by id,cdcta,year,level,ine_code,tipreig
SQL

    # select count(*) from tb_economica where id is null;
    # a lot of rows
  end

  def down
    execute "DELETE from tb_economica where id is null"
  end
end
