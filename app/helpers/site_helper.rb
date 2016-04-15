module SiteHelper

  def site_name
    if @site
      @site.institution_type + ' de ' + @site.location_name
    else
      'Gobierto Presupuestos Municipales'
    end
  end

  def site_url
    if @site
      @site.host
    else
      'presupuestos.gobierto.es'
    end
  end

end
