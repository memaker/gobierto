class Ranking
  def self.per_page
    25
  end

  def self.position(i, page)
    (page - 1)*self.per_page + i + 1
  end

  def self.page_from_position(position)
    (position.to_f / self.per_page.to_f).ceil
  end
end
