class PagesController < ApplicationController
  skip_before_action :authenticate, only: [:request_access]

  def home
  end
  
  def about
  end

  def request_access
  end

end
