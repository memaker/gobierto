class BudgetLinePresenter

  # {"ine_code"=>28079, "province_id"=>28, "autonomy_id"=>13, "year"=>2015,
  # "population"=>3141991, "amount"=>239124823.0, "code"=>"162", "level"=>3,
  # "kind"=>"G", "amount_per_inhabitant"=>76.11, "parent_code"=>"16"}
  # Merged with:
  #   - area
  #   - area_name
  #   - kind
  #   - total
  def initialize(attributes)
    @attributes = attributes.symbolize_keys
  end

  def name
    @attributes[:area].all_items[@attributes[:kind]][@attributes[:code]]
  end

  def amount
    @attributes[:amount]
  end

  def amount_per_inhabitant
    @attributes[:amount_per_inhabitant]
  end

  def percentage_of_total
    total = total || GobiertoBudgets::BudgetTotal.for(@attributes[:ine_code], @attributes[:year])
    amount.to_f / total.to_f
  end

  def total
    @attributes[:total]
  end

  def total_per_inhabitant
    @attributes[:total_budget_per_inhabitant]
  end

  def code
    @attributes[:code]
  end

  def level
    @attributes[:level]
  end

  def to_param
    {
      id: code, year: @attributes[:year],
      kind: @attributes[:kind],
      area_name: @attributes[:area_name]
    }
  end

end
