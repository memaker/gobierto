class SiteStats
  def initialize(options)
    @site = options.fetch :site
    @place = @site.place
    @year = options.fetch(:year).to_i
  end

  def total_budget_per_inhabitant(year = nil)
    year ||= @year
    total_budget_planned_query(year)['_source']['total_budget_per_inhabitant'].to_f
  end

  def total_budget(year = nil)
    year ||= @year
    total_budget_planned_query(year)['_source']['total_budget'].to_f
  end
  alias_method :total_budget_planned, :total_budget

  def total_budget_executed(year = nil)
    year ||= @year
    total_budget_executed_query(year)['_source']['total_budget']
  end

  def debt(year = nil)
    year ||= @year
    value = GobiertoBudgets::SearchEngine.client.get index: GobiertoBudgets::SearchEngineConfiguration::Data.index,
      type: GobiertoBudgets::SearchEngineConfiguration::Data.type_debt, id: [@place.id, year].join('/')
    value['_source']['value'] * 1000
  rescue Elasticsearch::Transport::Transport::Errors::NotFound
    nil
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

    "#{ActionController::Base.helpers.number_with_precision(diff, precision: 2)}% #{direction}"
  end

  private

  def total_budget_planned_query(year)
    GobiertoBudgets::SearchEngine.client.get index: GobiertoBudgets::SearchEngineConfiguration::TotalBudget.index_forecast,
      type: GobiertoBudgets::SearchEngineConfiguration::TotalBudget.type, id: [@place.id, year, GobiertoBudgets::BudgetLine::EXPENSE].join('/')
  rescue Elasticsearch::Transport::Transport::Errors::NotFound
    nil
  end

  def total_budget_executed_query(year)
    GobiertoBudgets::SearchEngine.client.get index: GobiertoBudgets::SearchEngineConfiguration::TotalBudget.index_executed,
      type: GobiertoBudgets::SearchEngineConfiguration::TotalBudget.type, id: [@place.id, year, GobiertoBudgets::BudgetLine::EXPENSE].join('/')
  rescue Elasticsearch::Transport::Transport::Errors::NotFound
    nil
  end
end
