class SearchEngine
  def self.client
    @client ||= Elasticsearch::Client.new log: false
  end
end
