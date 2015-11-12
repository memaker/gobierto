class Budget < OpenStruct
  def self.years
    (2010..2015).to_a.reverse
  end
end

