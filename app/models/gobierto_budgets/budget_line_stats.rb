module GobiertoBudgets
  class BudgetLineStats
    def initialize(options)
      @site = options.fetch :site
      @place = @site.place
      @budget_line = options.fetch :budget_line
      @kind = @budget_line.kind
      @area_name = @budget_line.area_name
      @year = @budget_line.year.to_i
      @code = @budget_line.code
    end

    def amount(year = nil)
      budget_line_planned_query(year, 'amount')
    end
    alias_method :amount_planned, :amount

    def amount_executed(year = nil)
      budget_line_executed_query(year, 'amount')
    end
    alias_method :amount_planned, :amount

    def amount_per_inhabitant(year = nil)
      budget_line_planned_query(year, 'amount_per_inhabitant')
    end

    def percentage_of_total(year = nil)
      (amount(year) / total_budget) * 100
    end

    def percentage_difference(options)
      year = options.fetch(:year, @year)
      variable1 = options.fetch(:variable1)
      variable2 = options.fetch(:variable2, options.fetch(:variable1))

      diff = if variable1 == variable2
               year1 = options.fetch(:year1)
               year2 = options.fetch(:year2)

               ((self.send(variable1, year1).to_f - self.send(variable1, year2).to_f)/self.send(variable1, year2).to_f) * 100
             else
               ((self.send(variable1, year).to_f - self.send(variable2, year).to_f)/self.send(variable2, year).to_f) * 100
             end

      if(diff < 0)
        direction = 'más'
        diff = diff*-1
      else
        direction = 'menos'
      end

      if diff == Float::INFINITY
        return nil
      else
        "#{ActionController::Base.helpers.number_with_precision(diff, precision: 2)}% #{direction}"
      end
    end

    private

    def total_budget
      total_budget_planned_query(@year, 'total_budget')
    end

    def budget_line_planned_query(year, attribute)
      year ||= @year
      result = GobiertoBudgets::SearchEngine.client.get index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast, type: @area_name, id: [@place.id, year, @code, @kind].join('/')
      result['_source'][attribute]
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      nil
    end

    def budget_line_executed_query(year, attribute)
      year ||= @year
      result = GobiertoBudgets::SearchEngine.client.get index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed, type: @area_name, id: [@place.id, year, @code, @kind].join('/')
      result['_source'][attribute]
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      nil
    end

    def total_budget_planned_query(year, attribute)
      result = GobiertoBudgets::SearchEngine.client.get index: GobiertoBudgets::SearchEngineConfiguration::TotalBudget.index_forecast,
        type: GobiertoBudgets::SearchEngineConfiguration::TotalBudget.type, id: [@place.id, year].join('/')
      result['_source'][attribute].to_f
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      nil
    end
  end
end
