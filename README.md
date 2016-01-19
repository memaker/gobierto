# Gobierto budget comparator

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
- document id: `<ine_code>/<year>/<code>/<kind>`. Example: `28079/2015/210/0`
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

### Generic data

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


