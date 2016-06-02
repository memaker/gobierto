class GobiertoBudgets::BudgetLineDescendant
    @sort_attribute ||= 'code'
    @sort_order ||= 'asc'

    def self.where(conditions)
      @conditions = conditions
      self
    end

    def self.all
      terms = [
        {term: { kind: @conditions[:kind] }},
        {term: { year: @conditions[:year] }},
        {term: { ine_code: @conditions[:place].id }}
      ]

      if @conditions[:parent_code]
        terms.push({term: { parent_code: @conditions[:parent_code] }})
      else
        terms.push({term: { level: 1 }})
      end

      query = {
        sort: [
          { @sort_attribute => { order: @sort_order } }
        ],
        query: {
          filtered: {
            filter: {
              bool: {
                must: terms
              }
            }
          }
        },
        size: 10_000
      }

      if @conditions[:area_name] == GobiertoBudgets::BudgetLine::ECONOMIC
        area = GobiertoBudgets::EconomicArea
      else
        area = GobiertoBudgets::FunctionalArea
      end

      response = GobiertoBudgets::SearchEngine.client.search index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast,
                                                             type: @conditions[:area_name], body: query

      response['hits']['hits'].map{ |h| h['_source'] }.map do |row|
        BudgetLinePresenter.new(row.merge({
          kind: @conditions[:kind], area_name: @conditions[:area_name], area: area
        }))
      end
    end

end
