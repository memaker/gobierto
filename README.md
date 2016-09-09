
![Gobierto](https://gobierto.es/assets/logo_gobierto.png)

# Gobierto

Gobierto is a web application that enables local administrations to communicate better with their constituents. It is composed of the following tools:

- Gobierto Budgets: A tool to enable citizens to explore, visualize, compare and contextualize budgets. Ideal for any public institution or governing body (like a municipality or autonomous region) that wants to publish their budget in a simple and user friendly way (see [madrid](madrid.gobierto.es) for an example) or a group of them (such as all the municipalities within an autonomous region. Explore all of Spain's municipal budgets [here](presupuestos.gobierto.es))
- Gobierto Participation: A tool for public bodies to create consultations on any subject, to ask questions and gather feedback and opinions
- Gobierto CMS: A simple CMS to create a hierarchy of static pages for informational purposes
- _more coming soon_

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
- Postgres
- Elastic Search
- Pow or another subdomains tool

### Setup the database and the secrets file

Once you have cloned the repository, do the following:

```
$ cd gobierto
$ cp config/database.yml.example config/database.yml
$ cp config/secrets.yml.example config/secrets.yml
$ bundle install
$ rake db:setup
```

### Setup Elastic Search

See [how](https://www.elastic.co/guide/en/elasticsearch/guide/current/running-elasticsearch.html)

Once it is running, make sure you enter the correct URL for your instance in `config/secrets.yml` under the `elastic_url` key

### Load some data

If you want to import some basic data to get started, do the following:

```
$ bin/rake gobierto_budgets:budgets:create
$ bin/rake gobierto_budgets:total_budget:create
$ bin/rake gobierto_budgets:budget_categories:create
$ bin/rake gobierto_budgets:places:create
$ bin/rake gobierto_budgets:debt:create
$ bin/rake gobierto_budgets:population:create
$ bin/sample_data
```

This will load data for X and Y municipalities in Spain as a sample.

Alternatively, learn [how to load the data](https://github.com/PopulateTools/gobierto/wiki/Loading-Gobierto-Data) for all or some municipalities in Spain.

### Setup subdomain and start the applictation

When working locally, the application server should be queried through the top-level domain `.gobierto.dev`.

To configure this host in your computer, the simplest way is through POW [POW](http://pow.cx/). To install:

```
$ curl get.pow.cx | sh
```

Then, configure the host like this:

```
$ cd ~/.pow
$ ln -s DIRECTORY/gobierto gobierto
```

Then just browse to http://presupuestos.gobierto.dev/ and the app should load.

### Setting up the site for a single public entity

PENDING

## Contributing

See [https://github.com/PopulateTools/gobierto/blob/master/CONTRIBUTING_EN.md] or [https://github.com/PopulateTools/gobierto/blob/master/CONTRIBUTING_ES.md]

## License

Code published under AFFERO GPL v3 (see [LICENSE-AGPLv3.txt](https://github.com/PopulateTools/gobierto/blob/master/LICENSE-AGPLv3.txt))
