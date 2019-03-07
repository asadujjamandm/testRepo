module RolesHelper
  def role_records_of
    @roles.count.to_s
  end

  def get_role_status(is_active)
    is_active == 'yes' ? 'Active' : 'Inactive'
  end

  def is_new_role
    @title == @localData['new_role']
  end

  def is_viewing_permissions
    @dirty_role.nil? && !@rolepermissions.nil?
  end

  def get_permission_role_name
    params[:role_name]
  end
end
