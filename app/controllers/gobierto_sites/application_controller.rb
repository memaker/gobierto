class GobiertoSites::ApplicationController < ApplicationController
  layout 'gobierto_site_application'

  if Rails.env.production?
    http_basic_authenticate_with name: "gobierto", password: "demo123"
  end
end
