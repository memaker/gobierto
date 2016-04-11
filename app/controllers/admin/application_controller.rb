class Admin::ApplicationController < ApplicationController
  layout 'gobierto_site_application'

  before_action :admin_user
end
