class PaginatedResult < OpenStruct
  def initialize(total_records, records)
    @total_records = total_records
    @records = records
  end

  attr_reader :total_records, :records
end
