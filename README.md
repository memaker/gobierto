
![Gobierto](https://gobierto.es/assets/logo_gobierto.png)

# Gobierto

Gobierto is a web application that enables local administrations to communicate better with their constituents. Here are some of the things you can do with it:

1. Setup a site for a municipality (such as madrid.gobierto.es) to publish their budgets in a well designed, easy to understand way. Soon also the site will incorporate other optional features such as a Participation module (where a consultation process can be put in place and fully managed), a Simple CMS and more.
2. Setup a multi-site installation to manage sites for multiple municipalities or public bodies at scale.
3. Deploy a budgets comparison tool to enable citizens to explore, visualize, compare and contextualize the budgets of multiple municipalities/public bodies at the same time (such as those of a given Province, Autonomous Region or Country)

Additionally:
- Optional integration with Mailchimp for simple user communication management
- User feedback gathering

## Application architecture

The application is written in the Ruby programming language and uses the Ruby on Rails framework. In the database layer uses Postgres. Also, it uses an external Elastic Search to store and process all the budgets and third-party data.

Gobierto budgets module lives in its own subdomain, and so does each of the individual sites for public bodies. This is the subdomains schema:

- `presupuestos.`, where Gobierto Budgets for more than one public entity lives
- `<public_entity_name>.`, is the public entity page where local budgets, cms module and participation module
  can be activated

## Development

### Software Requirements

- Git
- Ruby 2.3.1
- Rubygems
- PostgreSQL
- Elastic Search
- Pow or another subdomains tool

### Setup the database and the secrets file

Once you have PostgreSQL running and have cloned the repository, do the following:

```
$ cd gobierto
$ cp config/database.yml.example config/database.yml
$ cp config/secrets.yml.example config/secrets.yml
$ bundle install
$ rake db:setup
```

### Setup Elastic Search

See [how](https://www.elastic.co/guide/en/elasticsearch/guide/current/running-elasticsearch.html)

Once it is running, make sure you enter the correct URL for your Elastic Search instance in `config/secrets.yml` under the `elastic_url` key

### Load some data

If you want to import some basic data to get started, do the following:

1. Clone this repo and follow the instructions in order to have all of the Spanish Budgetary data available to load.
2. Run `bin/rake gobierto_budgets:setup:sample_site`

This will load data for Madrid, Barcelona and Bilbao and setup a site for Madrigal de la Vera.

Alternatively, learn [how to load the data](https://github.com/PopulateTools/gobierto/wiki/Loading-Gobierto-Data) for all or some municipalities in Spain.

### Setup subdomain and start the application

When working locally, the application server should be queried through the top-level domain `.gobierto.dev`.

To configure this host in your computer, the simplest way is through POW [POW](http://pow.cx/). To install:

```
curl get.pow.cx | sh
```

Then, configure the host like this:

```
cd ~/.pow
ln -s DIRECTORY/gobierto gobierto
```

Then just browse to http://presupuestos.gobierto.dev/ and the app should load.

### Setting up the site for a single public entity

Run:

```
bin/rake gobierto_budgets:setup:create_site['<Place ID>','<URL OF INSTITUTION>']
```
Where `<Place ID>` is the ID of the municipality you wish to setup the site for and the optional `<URL OF INSTITUTION>` is the URL for other municipality's website, if any.

## Contributing

See [https://github.com/PopulateTools/gobierto/blob/master/CONTRIBUTING_EN.md] or [https://github.com/PopulateTools/gobierto/blob/master/CONTRIBUTING_ES.md]

## License

Code published under AFFERO GPL v3 (see [LICENSE-AGPLv3.txt](https://github.com/PopulateTools/gobierto/blob/master/LICENSE-AGPLv3.txt))
