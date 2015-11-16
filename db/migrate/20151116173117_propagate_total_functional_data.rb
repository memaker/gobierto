class PropagateTotalFunctionalData < ActiveRecord::Migration
  def change
    ActiveRecord::Base.logger = nil
    (2010..2015).each do |year|
      INE::Places::Place.all.each do |place|
        if population = Population.find_by(codigo: place.id)
          population.update_column("total_functional_#{year}", FunctionalArea.total_budget(place.id, year))
        end
        putc '.'
      end
    end
  end
end
