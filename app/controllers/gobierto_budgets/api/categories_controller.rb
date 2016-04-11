module GobiertoBudgets
  module Api
    class CategoriesController < ApplicationController
      caches_page :index

      def index
        kind = params[:kind]
        area = params[:area]
        render_404 and return if area == 'functional' and kind == 'I'

        klass = area == 'economic' ? GobiertoBudgets::EconomicArea : GobiertoBudgets::FunctionalArea

        respond_to do |format|
          format.json do
            render json: Hash[klass.all_items[kind].sort_by{ |k,v| k.to_f }].to_json
          end
        end
      end
    end
  end
end
