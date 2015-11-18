class AddTotalEconomicIntoPlaces < ActiveRecord::Migration
  def up
    (2010..2015).each do |year|
      ['expending', 'incoming'].each do |kind|
        add_column :poblacion_municipal_2014, "total_economic_#{year}_#{kind}", :float

        INE::Places::Place.all.each do |place|
          if population = Population.find_by(codigo: place.id)
            population.update_column("total_economic_#{year}_#{kind}", EconomicArea.total_budget(kind == 'expending' ? 'G' : 'I', place.id, year))
          end
          putc '.'
        end
      end
    end
  end

  def down
    (2010..2015).each do |year|
      ['expending', 'incoming'].each do |kind|
        remove_column :poblacion_municipal_2014, "total_economic_#{year}_#{kind}"
      end
    end
  end
end
