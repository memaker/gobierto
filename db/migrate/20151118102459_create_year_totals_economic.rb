class CreateYearTotalsEconomic < ActiveRecord::Migration
  def up
    create_table :economic_yearly_totals, id: false do |t|
      t.string :cdcta, limit: 6, index: true
      t.integer :ine_code, index: true
      t.string :kind, limit: 1, index: true
      t.decimal :total_2010, precision: 15, scale: 2
      t.decimal :total_2011, precision: 15, scale: 2
      t.decimal :total_2012, precision: 15, scale: 2
      t.decimal :total_2013, precision: 15, scale: 2
      t.decimal :total_2014, precision: 15, scale: 2
      t.decimal :total_2015, precision: 15, scale: 2
    end

    sql = %{select cdcta,ine_code,year,importe as amount,tipreig from tb_economica
where ine_code IS NOT NULL order by cdcta, ine_code, year ASC}

    total_rows = ActiveRecord::Base.connection.execute(sql)
    total_rows.group_by {|row| [row['cdcta'],row['ine_code'],row['tipreig']] }.each do |g, values|
      total_amounts = ["'#{g[0]}'", g[1], "'#{g[2]}'"]
      (2010..2015).each do |year|
        if row = values.detect {|v| v['year'] == year.to_s }
          total_amounts << row['amount']
        else
          total_amounts << 'NULL'
        end
      end
      insert = "INSERT INTO economic_yearly_totals VALUES (#{total_amounts.join(',')})"
      # puts insert
      ActiveRecord::Base.connection.execute(insert)
    end
  end

  def down
    drop_table :economic_yearly_totals
  end
end
