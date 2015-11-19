require "net/http"
require "uri"

namespace :cache do
  desc 'Warm json caches'
  task :warm => :environment do
    def fetch(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      request.basic_auth("gobierto", "presupuestos")
      response = http.request(request)
    end

    BudgetFilter.years.each do |year|
      INE::Places::Place.all.each do |p|
        fetch URI.parse("http://presupuestos.gobierto.es/api/data/#{p.id}/#{year}/functional.json")
        fetch URI.parse("http://presupuestos.gobierto.es/api/data/#{p.id}/#{year}/G/economic.json")
        fetch URI.parse("http://presupuestos.gobierto.es/api/data/#{p.id}/#{year}/I/economic.json")
        sleep 1
        putc '.'
      end
      puts year
    end
  end
end
