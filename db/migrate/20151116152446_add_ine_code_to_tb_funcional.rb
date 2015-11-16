class AddIneCodeToTbFuncional < ActiveRecord::Migration
  def change
    add_column :tb_funcional, :ine_code, :integer
    add_column :tb_economica, :ine_code, :integer

    INE::Places::Place.all.each do |place|
      place_id = format('%.5i', place.id)

      if id = ActiveRecord::Base.connection.execute("select tb_funcional.id as id FROM tb_funcional INNER join tb_inventario ON tb_inventario.id = tb_funcional.id AND tb_inventario.codente = '#{place_id}AA000'").first.try(:[], 'id')
        ActiveRecord::Base.connection.execute("UPDATE tb_funcional SET ine_code = #{place_id.to_i} where id = '#{id}'")
      end

      if id = ActiveRecord::Base.connection.execute("select tb_economica.id as id FROM tb_economica INNER join tb_inventario ON tb_inventario.id = tb_economica.id AND tb_inventario.codente = '#{place_id}AA000'").first.try(:[], 'id')
        ActiveRecord::Base.connection.execute("UPDATE tb_economica SET ine_code = #{place_id.to_i} where id = '#{id}'")
      end
    end
  end
end
