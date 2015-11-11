module ApplicationHelper
  def money(amount)
    number_to_currency(amount, precision: 2, separator: ',', delimiter: '.', unit: '€', format: "%n %u")
  end
end
