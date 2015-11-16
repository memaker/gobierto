class AddTotalBudgetIntoPlaces < ActiveRecord::Migration
  def up
    (2010..2015).each do |year|
      add_column :poblacion_municipal_2014, "total_functional_#{year}", :float
    end
  end

  def down
    (2010..2015).each do |year|
      remove_column :poblacion_municipal_2014, "total_functional_#{year}"
    end
  end
end
