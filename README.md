# Gobierto

## Setup subdomain

The application server should be queried through the top-level domain `.gobierto.dev`.

To configure this host in your computer:

```
$ cd .pow
$ ln -s DIRECTORY/gobierto gobierto
```

Then just run `rails s` as usual, but type in the browser http://presupuestos.gobierto.dev/

## Elastic Search schema

### Budget categories

- indexes: `budget-categories`
- types: `categories`
- document id: `<area>/<code>/<kind>`. Example: `economic/30/G`
- schema:

```
  - area:                  { type: 'string', index: 'not_analyzed'  },
  - code:                  { type: 'string', index: 'not_analyzed'  },
  - name:                  { type: 'string', index: 'not_analyzed'  },
  - parent_code:           { type: 'string', index: 'not_analyzed'  },
  - level:                 { type: 'integer', index: 'not_analyzed' },
  - kind:                  { type: 'string', index: 'not_analyzed'  }, # income I / expense G
```

### Budget Line data

- indexes: `budgets-forecast`, `budgets-execution`
- types: `economic`, `functional`
- document id: `<ine_code>/<year>/<code>/<kind>`. Example: `28079/2015/210/G`
- schema:

```
  - ine_code:              { type: 'integer', index: 'not_analyzed' },
  - year:                  { type: 'integer', index: 'not_analyzed' },
  - amount:                { type: 'double', index: 'not_analyzed'  },
  - code:                  { type: 'string', index: 'not_analyzed'  },
  - parent_code:           { type: 'string', index: 'not_analyzed'  },
  - level:                 { type: 'integer', index: 'not_analyzed' },
  - kind:                  { type: 'string', index: 'not_analyzed'  }, # income I / expense G
  - province_id:           { type: 'integer', index: 'not_analyzed' },
  - autonomy_id:           { type: 'integer', index: 'not_analyzed' },
  - amount_per_inhabitant: { type: 'double', index: 'not_analyzed'  }
```

### Total budgets data

- indexes: `budgets-forecast`
- types: `total-budget`
- document id: `<ine_code>/<year>`. Example: `28079/2015`
- schema:

```
  - ine_code:                    { type: 'integer', index: 'not_analyzed' },
  - province_id:                 { type: 'integer', index: 'not_analyzed' },
  - autonomy_id:                 { type: 'integer', index: 'not_analyzed' },
  - year:                        { type: 'integer', index: 'not_analyzed' },
  - total_budget:                { type: 'double',  index: 'not_analyzed' },
  - total_budget_per_inhabitant: { type: 'double',  index: 'not_analyzed' }
```

### Population data

- indexes: `data`
- types: `population`
- document id: `<ine_code>/<year>`. Example: `28079/2015`
- schema:

```
  - ine_code:              { type: 'integer', index: 'not_analyzed' },
  - province_id:           { type: 'integer', index: 'not_analyzed' },
  - autonomy_id:           { type: 'integer', index: 'not_analyzed' },
  - year:                  { type: 'integer', index: 'not_analyzed' },
  - value:                 { type: 'integer', index: 'not_analyzed' }
```

### Places data

- indexes: `data`
- types: `places`
- document id: `<ine_code>`. Example: `28079`
- schema:

```
  - ine_code:              { type: 'integer', index: 'not_analyzed' },
  - province_id:           { type: 'integer', index: 'not_analyzed' },
  - autonomy_id:           { type: 'integer', index: 'not_analyzed' },
  - year:                  { type: 'integer', index: 'not_analyzed' },
  - name:                  { type: 'string',  index: 'analyzed', analyzer: 'spanish' }
```

### Debt data

- indexes: `data`
- types: `debt`
- document id: `<ine_code>/<year>`. Example: `28079/2014`
- schema:

```
  - ine_code:              { type: 'integer', index: 'not_analyzed' },
  - province_id:           { type: 'integer', index: 'not_analyzed' },
  - autonomy_id:           { type: 'integer', index: 'not_analyzed' },
  - year:                  { type: 'integer', index: 'not_analyzed' },
  - value:                 { type: 'double', index: 'not_analyzed' }
```


## Load the data


### Load planned data

```
# Load budgets
bin/rake budgets:import['budgets-planned','budgets-forecast-v2','economic',2015] && 
bin/rake budgets:import['budgets-planned','budgets-forecast-v2','economic',2014] &&
bin/rake budgets:import['budgets-planned','budgets-forecast-v2','economic',2013] &&
bin/rake budgets:import['budgets-planned','budgets-forecast-v2','economic',2012] &&
bin/rake budgets:import['budgets-planned','budgets-forecast-v2','economic',2011] &&
bin/rake budgets:import['budgets-planned','budgets-forecast-v2','economic',2010] &&
bin/rake budgets:import['budgets-planned','budgets-forecast-v2','functional',2015] && 
bin/rake budgets:import['budgets-planned','budgets-forecast-v2','functional',2014] &&
bin/rake budgets:import['budgets-planned','budgets-forecast-v2','functional',2013] &&
bin/rake budgets:import['budgets-planned','budgets-forecast-v2','functional',2012] &&
bin/rake budgets:import['budgets-planned','budgets-forecast-v2','functional',2011] &&
bin/rake budgets:import['budgets-planned','budgets-forecast-v2','functional',2010]

# Load total aggregations
bin/rake total_budget:import['budgets-forecast-v2',2015] && 
bin/rake total_budget:import['budgets-forecast-v2',2014] &&
bin/rake total_budget:import['budgets-forecast-v2',2013] &&
bin/rake total_budget:import['budgets-forecast-v2',2012] &&
bin/rake total_budget:import['budgets-forecast-v2',2011] &&
bin/rake total_budget:import['budgets-forecast-v2',2010]
```

### Load executed data

```
# Load budgets
bin/rake budgets:import['budgets-executed','budgets-execution-v2','economic',2014] &&
bin/rake budgets:import['budgets-executed','budgets-execution-v2','economic',2013] &&
bin/rake budgets:import['budgets-executed','budgets-execution-v2','economic',2012] &&
bin/rake budgets:import['budgets-executed','budgets-execution-v2','economic',2011] &&
bin/rake budgets:import['budgets-executed','budgets-execution-v2','economic',2010] &&
bin/rake budgets:import['budgets-executed','budgets-execution-v2','functional',2014] &&
bin/rake budgets:import['budgets-executed','budgets-execution-v2','functional',2013] &&
bin/rake budgets:import['budgets-executed','budgets-execution-v2','functional',2012] &&
bin/rake budgets:import['budgets-executed','budgets-execution-v2','functional',2011] &&
bin/rake budgets:import['budgets-executed','budgets-execution-v2','functional',2010]

# Load total aggregations
bin/rake total_budget:import['budgets-execution-v2',2014] &&
bin/rake total_budget:import['budgets-execution-v2',2013] &&
bin/rake total_budget:import['budgets-execution-v2',2012] &&
bin/rake total_budget:import['budgets-execution-v2',2011] &&
bin/rake total_budget:import['budgets-execution-v2',2010]
```
