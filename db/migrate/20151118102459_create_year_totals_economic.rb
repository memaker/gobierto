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

    ActiveRecord::Base.logger = nil
    EconomicArea.items.all.each do |category|
      INE::Places::Place.all.each do |place|
        sql = <<-SQL
select importe as amount, year
FROM tb_economica
WHERE ine_code = #{place.id} AND tb_economica.cdcta = '#{category.code}' AND idente is null
AND tipreig = '#{category.tipreig}'
ORDER BY year ASC
SQL

        results = ActiveRecord::Base.connection.execute(sql)

        values = []
        values << (results.detect{|r| r['year'] == '2010'}.try(:[], 'amount') || 0)
        values << (results.detect{|r| r['year'] == '2011'}.try(:[], 'amount') || 0)
        values << (results.detect{|r| r['year'] == '2012'}.try(:[], 'amount') || 0)
        values << (results.detect{|r| r['year'] == '2013'}.try(:[], 'amount') || 0)
        values << (results.detect{|r| r['year'] == '2014'}.try(:[], 'amount') || 0)
        values << (results.detect{|r| r['year'] == '2015'}.try(:[], 'amount') || 0)

        sql = <<-SQL
INSERT INTO economic_yearly_totals VALUES ('#{category.code}', #{place.id}, '#{category.kind}',
        #{values[0]},
        #{values[1]},
        #{values[2]},
        #{values[3]},
        #{values[4]},
        #{values[5]})
SQL
        ActiveRecord::Base.connection.execute(sql)

      end
      putc '.'
    end.size
  end

  def down
    drop_table :economic_yearly_totals
  end
end
