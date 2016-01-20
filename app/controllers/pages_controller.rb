class PagesController < ApplicationController
  skip_before_action :authenticate, only: [:request_access]

  def home
  end
  
  def about
  end

  def pro
  end

  def request_access
    render layout: false
  end

end
