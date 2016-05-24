module GobiertoBudgets
  class SearchEngineConfiguration
    class Year
      def self.last; 2015 end
    end

    class BudgetCategories
      def self.index; 'budget-categories' end
      def self.type; 'categories' end
    end

    class BudgetLine
      def self.index_forecast; 'budgets-forecast-v2' end
      def self.index_executed; 'budgets-execution-v2' end
      # TODO: add the types economic and functional
    end

    class TotalBudget
      def self.index_forecast; 'budgets-forecast-v2' end
      def self.index_executed; 'budgets-execution-v2' end
      def self.type; 'total-budget' end
    end

    class Data
      def self.index; 'data' end
      def self.type_population; 'population' end
      def self.type_places; 'places-v2' end
      def self.type_debt; 'debt' end
    end

  end
end
