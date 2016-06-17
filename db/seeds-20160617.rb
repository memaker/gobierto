urls = {
  'Molina de Segura' => 'http://portal.molinadesegura.es',
  'Murcia' => 'http://murcia.es',
  'Cartagena' => 'http://www.cartagena.es',
  'Lorca' => 'http://www.lorca.es'
}

['Molina de Segura', 'Murcia', 'Cartagena', 'Lorca'].each do |name|
  place = INE::Places::Place.find_by_name name

  if place.nil?
    raise "#{name} not found"
  end

  domain = [place.slug, 'gobierto', Rails.env.production? ? 'es' : 'dev'].join('.')

  site = Site.create! name: place.name, domain: domain, location_name: place.name, location_type: place.class.name,
    external_id: place.id, institution_url: urls[place.name], institution_type: 'Ayuntamiento'

  site.configuration.links = [urls[place.name]]
  site.configuration.modules = ['GobiertoBudgets']
  site.save!
end
