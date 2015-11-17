class BudgetLine < OpenStruct
  def amount
    super.to_f
  end

  def population
    super.to_i
  end

  def total_functional_budget
    super.to_f
  end

  def place
    @place ||= INE::Places::Place.find(place_id).tap do |place|
      if place.nil?
        Rails.logger.info "======================================================"
        Rails.logger.info "[WARNING] #{place_id} is nil"
        Rails.logger.info "======================================================"
      end
    end
  end

  def historic_values
    [total_2010,total_2011,total_2012,total_2013,total_2014,total_2015]
  end
end
