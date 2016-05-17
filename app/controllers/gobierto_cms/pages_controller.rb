module GobiertoCms
  class PagesController < GobiertoCms::ApplicationController

    def index
      @pages = @site.gobierto_cms_pages.root.sorted
    end

    def show
      @page = @site.gobierto_cms_pages.friendly.find(params[:id])

      admin_add_link new_admin_gobierto_cms_page_path
      admin_edit_link edit_admin_gobierto_cms_page_path(@page)
      admin_remove_link admin_gobierto_cms_page_path(@page)
    end
  end
end
