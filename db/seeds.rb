## Órgiva
place = INE::Places::Place.find_by_slug 'orgiva'

site = Site.create! name: 'Órgiva Participa', domain: 'orgiva.gobierto.dev', location_name: 'Órgiva', location_type: place.class.name,
  external_id: place.id, institution_url: 'http://orgiva.es', institution_type: 'Ayuntamiento'

GobiertoCms::Page.create! title: 'Sobre el ayuntamiento', body: 'Sobre el ayuntamiento body', site: site


## Burjassot
place = INE::Places::Place.find_by_slug 'burjassot'

site = Site.create! name: 'Burjassot Transparente', domain: 'gobierto.burjassot.dev', location_name: 'Burjassot', location_type: place.class.name,
  external_id: place.id, institution_url: 'http://burjassot.es', institution_type: 'Ayuntamiento'

GobiertoCms::Page.create! title: 'Sobre el ayuntamiento', body: 'Sobre el ayuntamiento body', site: site
