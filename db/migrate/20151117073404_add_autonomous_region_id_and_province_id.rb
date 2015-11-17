class AddAutonomousRegionIdAndProvinceId < ActiveRecord::Migration
  def change
    add_column :poblacion_municipal_2014, :province_id, :integer, index: true
    add_column :poblacion_municipal_2014, :autonomous_region_id, :integer, index: true

    Population.find_each do |p|
      next if p.place.nil?

      p.update_columns province_id: p.place.province.id, autonomous_region_id: p.place.province.autonomous_region.id
      putc '.'
    end
  end
end
