class CategoriesController < ApplicationController
  def economic
    @kind = params[:kind] if %W(G I).include?(params[:kind])
    respond_to do |format|
      format.js
    end
  end
end
