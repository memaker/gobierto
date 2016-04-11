module SiteHelper

  def site_name
    @site.institution_type + ' de ' + @site.location_name
  end

  def site_url
    @site.host
  end

end
