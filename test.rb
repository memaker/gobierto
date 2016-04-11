require 'json'
require 'insights_snitcher'

dictionary = JSON.parse(File.read('functional-G.json'))

dataset = 'madrid-total.json'
context = {
  data_column: 'total_budget',
  time_column: 'year',
  template_variables: {
    unit: '€',
    concept: 'presupuesto total',
    subject: 'Madrid'
  }
}

snitcher = InsightsSnitcher::Detector.new dataset: dataset, context: context
output = snitcher.detect

dataset = 'madrid-functional-G.json'

dictionary.each do |code, description|

  context = {
    data_column: 'amount',
    time_column: 'year',
    filters: {
      code: code
    },
    template_variables: {
      unit: '€',
      concept: 'gasto en ' + description.downcase,
      subject: 'Madrid'
    }
  }

  snitcher = InsightsSnitcher::Detector.new dataset: dataset, context: context
  output = snitcher.detect
  debugger

  puts
end
