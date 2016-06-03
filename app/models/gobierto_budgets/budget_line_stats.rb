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
      budget_line_planned_query(year)['_source']['amount']
    end
    alias_method :amount_planned, :amount

    def amount_executed(year = nil)
      budget_line_executed_query(year)['_source']['amount']
    end
    alias_method :amount_planned, :amount

    def amount_per_inhabitant(year = nil)
      budget_line_planned_query(year)['_source']['amount_per_inhabitant']
    end

    def percentage_of_total(year = nil)
      (budget_line_planned_query(year)['_source']['amount'] / total_budget) * 100
    end

    def percentage_difference(options)
      year = options.fetch(:year, @year)
      variable1 = options.fetch(:variable1)
      variable2 = options.fetch(:variable2, options.fetch(:variable1))
      diff = ((self.send(variable1, year).to_f - self.send(variable2, year).to_f)/self.send(variable2, year).to_f) * 100
      if(diff < 0)
        direction = 'más'
        diff = diff*-1
      else
        direction = 'menos'
      end

      "#{ActionController::Base.helpers.number_with_precision(diff, precision: 2)}% #{direction}"
    end

    private

    def total_budget
      total_budget_planned_query(@year)['_source']['total_budget'].to_f
    end

    def budget_line_planned_query(year = nil)
      year ||= @year
      GobiertoBudgets::SearchEngine.client.get index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_forecast, type: @area_name, id: [@place.id, year, @code, @kind].join('/')
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      nil
    end

    def budget_line_executed_query(year = nil)
      year ||= @year
      GobiertoBudgets::SearchEngine.client.get index: GobiertoBudgets::SearchEngineConfiguration::BudgetLine.index_executed, type: @area_name, id: [@place.id, year, @code, @kind].join('/')
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      nil
    end

    def total_budget_planned_query(year)
      GobiertoBudgets::SearchEngine.client.get index: GobiertoBudgets::SearchEngineConfiguration::TotalBudget.index_forecast,
        type: GobiertoBudgets::SearchEngineConfiguration::TotalBudget.type, id: [@place.id, year].join('/')
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      nil
    end
  end
end
