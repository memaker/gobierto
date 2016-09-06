# Gobierto

Gobierto is a software focused in helping the local administration to communicate better with the
citiziens. It is composed of the following tools:

- budget comparator and explorer module
- participation module: allows to ask questions and opinions
- CMS module to create a hierarchy of static pages
- user communication management via Mailchimp
- user feedback gathering
- _more coming soon_

## Application architecture

The application is implemented using Ruby programming language and Ruby on Rails framework. In the
database layer uses Postgres. Also, it uses an external Elastic Search to store and process all the
budgets and third-party data.

Every module lives in a subdomain. This is the subdomains schema:

- `presupuestos.`, where the budget comparing tool lives
- `<municipality_name>.`, is the municipality page where local budgets, cms module and participation module
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

Once you have cloned the repository, create a file `config/database.yml` based on `config/database.yml.example`. Do the same with the `config/secrets.yml.example` file.

### Setup subdomain and start the applictation

The application server should be queried through the top-level domain `.gobierto.dev`.

To configure this host in your computer, the simplest way is through POW [POW](http://pow.cx/). To install:

```
$ curl get.pow.cx | sh
```

Then, configure the host like this:

```
$ cd ~/.pow
$ ln -s DIRECTORY/gobierto gobierto
```

Then just run `rails s` as usual, but type in the browser http://presupuestos.gobierto.dev/

### Load the data

#### Create schemas

bin/rake gobierto_budgets:budgets:create
bin/rake gobierto_budgets:total_budget:create
bin/rake gobierto_budgets:budget_categories:create
bin/rake gobierto_budgets:places:create
bin/rake gobierto_budgets:debt:create
bin/rake gobierto_budgets:population:create

#### Load planned data

```
# Load categories
bin/rake gobierto_budgets:budget_categories:import['budgets-planned']

# Load places
bin/rake gobierto_budgets:places:import

# Load debt
bin/rake gobierto_budgets:debt:import[2015,'db/data/debt/debt-2015.csv'] &&
bin/rake gobierto_budgets:debt:import[2014,'db/data/debt/debt-2014.csv'] &&
bin/rake gobierto_budgets:debt:import[2013,'db/data/debt/debt-2013.csv'] &&
bin/rake gobierto_budgets:debt:import[2012,'db/data/debt/debt-2012.csv'] &&
bin/rake gobierto_budgets:debt:import[2011,'db/data/debt/debt-2011.csv'] &&
bin/rake gobierto_budgets:debt:import[2010,'db/data/debt/debt-2010.csv']

# Load population
bin/rake gobierto_budgets:population:import[2015,'db/data/population/2015.px'] &&
bin/rake gobierto_budgets:population:import[2014,'db/data/population/2014.px'] &&
bin/rake gobierto_budgets:population:import[2013,'db/data/population/2013.px'] &&
bin/rake gobierto_budgets:population:import[2012,'db/data/population/2012.px'] &&
bin/rake gobierto_budgets:population:import[2011,'db/data/population/2011.px'] &&
bin/rake gobierto_budgets:population:import[2010,'db/data/population/2011.px']

# Load budgets
bin/rake gobierto_budgets:budgets:import['budgets-planned','budgets-forecast-v2','economic',2015] &&
bin/rake gobierto_budgets:budgets:import['budgets-planned','budgets-forecast-v2','economic',2014] &&
bin/rake gobierto_budgets:budgets:import['budgets-planned','budgets-forecast-v2','economic',2013] &&
bin/rake gobierto_budgets:budgets:import['budgets-planned','budgets-forecast-v2','economic',2012] &&
bin/rake gobierto_budgets:budgets:import['budgets-planned','budgets-forecast-v2','economic',2011] &&
bin/rake gobierto_budgets:budgets:import['budgets-planned','budgets-forecast-v2','economic',2010] &&
bin/rake gobierto_budgets:budgets:import['budgets-planned','budgets-forecast-v2','functional',2015] &&
bin/rake gobierto_budgets:budgets:import['budgets-planned','budgets-forecast-v2','functional',2014] &&
bin/rake gobierto_budgets:budgets:import['budgets-planned','budgets-forecast-v2','functional',2013] &&
bin/rake gobierto_budgets:budgets:import['budgets-planned','budgets-forecast-v2','functional',2012] &&
bin/rake gobierto_budgets:budgets:import['budgets-planned','budgets-forecast-v2','functional',2011] &&
bin/rake gobierto_budgets:budgets:import['budgets-planned','budgets-forecast-v2','functional',2010]

# Load total aggregations
bin/rake gobierto_budgets:total_budget:import['budgets-forecast-v2',2015] && 
bin/rake gobierto_budgets:total_budget:import['budgets-forecast-v2',2014] &&
bin/rake gobierto_budgets:total_budget:import['budgets-forecast-v2',2013] &&
bin/rake gobierto_budgets:total_budget:import['budgets-forecast-v2',2012] &&
bin/rake gobierto_budgets:total_budget:import['budgets-forecast-v2',2011] &&
bin/rake gobierto_budgets:total_budget:import['budgets-forecast-v2',2010]
```

#### Load executed data

```
# Load budgets
bin/rake gobierto_budgets:budgets:import['budgets-executed','budgets-execution-v2','economic',2015] &&
bin/rake gobierto_budgets:budgets:import['budgets-executed','budgets-execution-v2','economic',2014] &&
bin/rake gobierto_budgets:budgets:import['budgets-executed','budgets-execution-v2','economic',2013] &&
bin/rake gobierto_budgets:budgets:import['budgets-executed','budgets-execution-v2','economic',2012] &&
bin/rake gobierto_budgets:budgets:import['budgets-executed','budgets-execution-v2','economic',2011] &&
bin/rake gobierto_budgets:budgets:import['budgets-executed','budgets-execution-v2','economic',2010] &&
bin/rake gobierto_budgets:budgets:import['budgets-executed','budgets-execution-v2','functional',2015] &&
bin/rake gobierto_budgets:budgets:import['budgets-executed','budgets-execution-v2','functional',2014] &&
bin/rake gobierto_budgets:budgets:import['budgets-executed','budgets-execution-v2','functional',2013] &&
bin/rake gobierto_budgets:budgets:import['budgets-executed','budgets-execution-v2','functional',2012] &&
bin/rake gobierto_budgets:budgets:import['budgets-executed','budgets-execution-v2','functional',2011] &&
bin/rake gobierto_budgets:budgets:import['budgets-executed','budgets-execution-v2','functional',2010]

# Load total aggregations
bin/rake gobierto_budgets:total_budget:import['budgets-execution-v2',2015] &&
bin/rake gobierto_budgets:total_budget:import['budgets-execution-v2',2014] &&
bin/rake gobierto_budgets:total_budget:import['budgets-execution-v2',2013] &&
bin/rake gobierto_budgets:total_budget:import['budgets-execution-v2',2012] &&
bin/rake gobierto_budgets:total_budget:import['budgets-execution-v2',2011] &&
bin/rake gobierto_budgets:total_budget:import['budgets-execution-v2',2010]
```

#### Load local data

In case you want to load only the data from a municipality, province or autonomous region, in the
tasks that load the budgets or the total aggregations you can use an argument to declare which
region you want to import the data from. There are three different arguments:

- `place_id`. Example: `bin/rake gobierto_budgets:budgets:import['budgets-planned','budgets-forecast-v2','economic',2015] place_id=28079`
- `province_id`. Example: `bin/rake gobierto_budgets:budgets:import['budgets-planned','budgets-forecast-v2','economic',2015] province_id=1`
- `autonomous_region_id`. Example: `bin/rake gobierto_budgets:budgets:import['budgets-planned','budgets-forecast-v2','economic',2015] autonomous_region_id=1`

You can check the different IDs in these tables:

- [places IDs](https://github.com/PopulateTools/ine-places/blob/master/lib/ine/places/data/places.csv)
- [provinces IDs](https://github.com/PopulateTools/ine-places/blob/master/lib/ine/places/data/provinces.csv)
- [autonomous regions IDs](https://github.com/PopulateTools/ine-places/blob/master/lib/ine/places/data/autonomous_regions.csv)

#### Datasets

- Debt: http://www.minhap.gob.es/es-ES/Areas%20Tematicas/Administracion%20Electronica/OVEELL/Paginas/DeudaViva.aspx
- Population: http://www.ine.es/inebmenu/mnu_cifraspob.htm
