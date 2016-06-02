## Órgiva
place = INE::Places::Place.find_by_slug 'orgiva'

site = Site.create! name: 'Órgiva Participa', domain: 'orgiva.gobierto.dev', location_name: 'Órgiva', location_type: place.class.name,
  external_id: place.id, institution_url: 'http://orgiva.es', institution_type: 'Ayuntamiento'

site.configuration.links = ['http://orgiva.es']
site.configuration.logo = 'http://www.aytoorgiva.org/web/sites/all/themes/aytoorgiva_COPSEG/logo.png'
site.configuration.modules = ['GobiertoParticipation', 'GobiertoBudgets']
site.save!

site.gobierto_cms_pages.create! title: 'Sobre el ayuntamiento', body: 'Sobre el ayuntamiento body'

## Burjassot
place = INE::Places::Place.find_by_slug 'burjassot'

site = Site.create! name: 'Burjassot Transparente', domain: 'gobierto.burjassot.dev', location_name: 'Burjassot', location_type: place.class.name,
  external_id: place.id, institution_url: 'http://burjassot.es', institution_type: 'Ayuntamiento'

site.configuration.links = ['http://burjassot.es']
site.configuration.logo = 'http://www.burjassot.org/wp-content/themes/ajuntament/images/_logo-burjassot.jpg'
site.configuration.modules = ['GobiertoParticipation']
site.save!

site.gobierto_cms_pages.create! title: 'Sobre el ayuntamiento', body: 'Sobre el ayuntamiento body'

## Santander
place = INE::Places::Place.find_by_slug 'santander'

site = Site.create! name: 'Santander Participa', domain: 'santander.gobierto.dev', location_name: 'Santander', location_type: place.class.name,
  external_id: place.id, institution_url: 'http://santander.es', institution_type: 'Ayuntamiento'

site.configuration.links = ['http://santander.es']
site.configuration.logo = 'http://santander.es/sites/default/themes/custom/ayuntamiento/img/logo-ayto-santander.png'
site.configuration.modules = ['GobiertoParticipation', 'GobiertoBudgets']
site.save!

site.gobierto_cms_pages.create! title: 'Sobre el ayuntamiento', body: 'Sobre el ayuntamiento body'

## Create Admin
u = User.new email: 'admin@example.com', password: 'admin123', password_confirmation: 'admin123', place_id: Site.first.place.id, first_name: 'Admin', last_name: 'Admin', admin: true
u.save!
u.clear_verification_token
u.terms_of_service = true
u.save!
