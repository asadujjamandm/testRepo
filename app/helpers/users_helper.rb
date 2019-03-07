module UsersHelper
  def user_records_of
    @users.count.to_s
  end

  def get_user_status(is_active)
    is_active == 'yes' ? 'Active' : 'Inactive'
  end

  def is_new_user
    @title == @localData['new_user']
  end

  def is_viewing_roles
    @dirty_user.nil? && !@userroles.nil?
  end

  def get_role_user_name
    params[:user_name]
  end

  def get_role_name_status_role(role)
    role.name + ' (' + (role.is_active == 'yes' ? 'Active' : 'Inactive') + ')'
  end

  def get_role_name_status_userrole(user_role)
    user_role.role_name + ' (' + (user_role.is_role_active? ? 'Active' : 'Inactive') + ')'
  end

  def get_user_statuses
    [['', ''].to_a, ['yes', 'Active'].to_a, ['no', 'Inactive'].to_a].to_a
  end
end
