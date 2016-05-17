class Site < ActiveRecord::Base

  RESERVED_SUBDOMAINS = %W(presupuestos)

  has_many :gobierto_cms_pages, class_name: GobiertoCms::Page
  has_many :gobierto_participation_ideas, class_name: GobiertoParticipation::Idea
  has_many :gobierto_participation_consultations, class_name: GobiertoParticipation::Consultation

  serialize :configuration_data

  before_save :store_configuration

  validates :name, presence: true, uniqueness: true
  validates :location_name, presence: true
  validates :institution_url, presence: true

  validates :domain, presence: true, uniqueness: true, domain: true

  def self.reserved_domain?(domain)
    RESERVED_SUBDOMAINS.map do |subdomain|
      "#{subdomain}." + Settings.gobierto_host
    end.any?{ |reserved_domain| domain == reserved_domain }
  end

  def self.budgets_domain?(domain)
    domain == "presupuestos." + Settings.gobierto_host
  end

  def subdomain
    if domain.present? and domain.include?('.')
      domain.split('.').first
    end
  end

  def configuration
    @configuration ||= SiteConfiguration.new(read_attribute(:configuration_data))
  end

  private

  def store_configuration
    self.configuration_data = self.configuration.to_h
  end
end
