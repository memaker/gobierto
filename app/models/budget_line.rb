class BudgetLine < OpenStruct
  def amount
    super.to_f
  end

  def place
    @place ||= INE::Places::Place.find(place_id).tap do |place|
      if place.nil?
        Rails.logger.info "======================================================"
        Rails.logger.info "[WARNING] #{place_id} is nil"
        Rails.logger.info "======================================================"
      else
        place.total_budget ||= FunctionalArea.total_budget(place_id, self.year)
        place.population ||= Population.select('total').by_place_id(place_id).total
      end
    end
  end

  def historic_values
    sql = <<-SQL
select sum(importe) as amount
FROM tb_funcional
INNER join tb_inventario ON tb_inventario.id = tb_funcional.id AND tb_inventario.codente = '#{format('%.5i', place.id)}AA000'
WHERE tb_funcional.cdfgr = '#{code}'
GROUP BY tb_funcional.cdfgr, tb_funcional.year
ORDER BY year ASC
    SQL

    ActiveRecord::Base.connection.execute(sql).map{|row| row['amount'] }
  end
end
