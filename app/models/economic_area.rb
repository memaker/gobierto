class EconomicArea < ActiveRecord::Base
  EXPENSE = 'G'
  INCOME  = 'I'

  self.table_name = "tb_cuentasEconomica"

  def self.all_items
    @all_items ||= begin
      all_items = {
        EXPENSE => {},
        INCOME => {}
      }

      self.all.each do |category|
        all_items[category.tipreig][category.cdcta] = category.nombre
      end

      all_items
    end
  end

end
