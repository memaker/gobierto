class Population < ActiveRecord::Base
  self.table_name = 'poblacion_municipal_2014'
  self.primary_key = 'codigo'

  scope :by_place_id, -> (place_id) { find_by(codigo: place_id) }

end
