class Admin::ApplicationController < ApplicationController
  layout 'gobierto_participation_application'

  before_action :admin_user
end
