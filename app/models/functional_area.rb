class FunctionalArea < ActiveRecord::Base
  EXPENSE = 'G'

  self.table_name = "tb_cuentasProgramas"

  def self.all_items
    @all_items ||= begin
      all_items = {
        EXPENSE => {}
      }

      self.all.each do |category|
        all_items[EXPENSE][category.cdfgr] = category.nombre
      end

      all_items
    end
  end

end
