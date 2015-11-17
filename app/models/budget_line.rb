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
    sql = <<-SQL
select importe as amount
FROM tb_funcional
WHERE cdfgr = '#{code}' AND ine_code = #{place.id} AND cdcta is null
ORDER BY year ASC
    SQL

    ActiveRecord::Base.connection.execute(sql).map{|row| row['amount'] }
  end
end
