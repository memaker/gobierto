module GobiertoCms::PagesHelper
  def render_children_pages(page)
    children = page.children.all.to_a
    return "" if children.empty?

    "<ul>
      #{page.children.map do |child_page|
        %Q{<li id="page_#{child_page.id}">#{render(partial: 'admin/gobierto_cms/pages/page', locals: {page: child_page})} #{render_children_pages(child_page)}</li>}
      end.join("\n")}
    </ul>".html_safe
  end

  def parent_pages(current_page)
    pages = [["Pagina raiz", nil]]

    GobiertoCms::Page.walk_tree do |page, level|
      next if page == current_page
      pages << ["#{'-'*level} #{page.title}", page.id]
    end

    pages
  end

  def gobierto_cms_pages_breadcrumb
    ([link_to(t('gobierto_cms.pages_root'), gobierto_cms_root_path, title: t('gobierto_cms.pages_root'))] + @page.parents.map{ |p| link_to(p.title, p) }).join(' » ').html_safe
  end
end
