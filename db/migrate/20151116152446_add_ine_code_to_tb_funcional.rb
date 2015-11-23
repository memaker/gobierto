class AddIneCodeToTbFuncional < ActiveRecord::Migration
  def change
    add_column :tb_funcional, :ine_code, :integer
    add_column :tb_economica, :ine_code, :integer

    INE::Places::Place.all.each do |place|
      year = 2010
      place_id = format('%.5i', place.id)

      find_query = <<-SQL
select tb_funcional.id as id
FROM tb_funcional
INNER join tb_inventario ON tb_inventario.id = tb_funcional.id AND tb_inventario.codente = '#{place_id}AA000'
SQL

      id = ActiveRecord::Base.connection.execute(find_query).first.try(:[], 'id')
      while id.nil? and year < 2015
        find_query = <<-SQL
select tb_funcional.id as id
FROM tb_funcional
INNER join tb_inventario_#{year} ON tb_inventario_#{year}.id = tb_funcional.id AND tb_inventario_#{year}.codente = '#{place_id}AA000'
SQL
        year+=1
        id = ActiveRecord::Base.connection.execute(find_query).first.try(:[], 'id')
      end

      if id.nil?
        puts place.name
        puts 
      else
        ActiveRecord::Base.connection.execute("UPDATE tb_funcional SET ine_code = #{place_id.to_i} where id = '#{id}'")
        ActiveRecord::Base.connection.execute("UPDATE tb_economica SET ine_code = #{place_id.to_i} where id = '#{id}'")
      end
    end

    # We can delete the lines which ine_code can't be matched
    # At this point 7982 places have budget
    #
    # select count(distinct(ine_code)) from tb_funcional;
    #  count
    # -------
    #   7982
    ActiveRecord::Base.connection.execute("DELETE from tb_economica where ine_code is null")
    ActiveRecord::Base.connection.execute("DELETE from tb_funcional where ine_code is null")
  end
end
