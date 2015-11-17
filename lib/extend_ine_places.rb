class INE::Places::AutonomousRegion
  class << self
    def collection_for_search(name)
      filter(collection_klass.records, name).map do |autonomous_region|
        {
          value: autonomous_region.name,
          data: {
            category: 'Comunidad Autónoma',
            id: autonomous_region.id,
            type: self.name.demodulize
          }
        }
      end
    end
  end
end

class INE::Places::Province
  class << self
    def collection_for_search(name)
      filter(collection_klass.records, name).map do |province|
        {
          value: province.name,
          data: {
            category: 'Provincia',
            id: province.id,
            type: self.name.demodulize
          }
        }
      end
    end
  end
end

class INE::Places::Place
  class << self
    def collection_for_search(name)
      filter(collection_klass.records, name).map do |place|
        {
          value: place.name,
          data: {
            category: place.province.name,
            id: place.id,
            type: self.name.demodulize
          }
        }
      end
    end
  end

  def data
    @data ||= Population.find_by(codigo: self.id)
  end

end
