module AdminHelper
  def admin_can_add?
    @admin_add_controls.present?
  end

  def admin_add_path
    @admin_add_controls
  end

  def admin_can_edit?
    @admin_edit_controls.present?
  end

  def admin_edit_path
    @admin_edit_controls
  end

  def admin_can_remove?
    @admin_remove_controls.present?
  end

  def admin_remove_path
    @admin_remove_controls
  end
end
