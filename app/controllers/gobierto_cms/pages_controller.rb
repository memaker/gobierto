module GobiertoCms
  class PagesController < GobiertoCms::ApplicationController

    def index
      @pages = GobiertoCms::Page.root.sorted
    end

    def show
      @page = GobiertoCms::Page.friendly.find(params[:id])

      admin_add_link new_admin_gobierto_cms_page_path
      admin_edit_link edit_admin_gobierto_cms_page_path(@page)
      admin_remove_link admin_gobierto_cms_page_path(@page)
    end
  end
end
