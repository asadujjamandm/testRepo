module UserUtils
  def self.make_user_post_data(postdata, u)
    postdata.merge!({"id" => u.id})
    postdata.merge!({"name" => u.name})
    postdata.merge!({"password" => u.password})
    postdata.merge!({"email" => u.email})
    postdata.merge!({"isactive" => u.is_active})
    postdata.merge!({"timekeeperid" => u.timekeeper_id})
  end

  def self.make_user_role_post_data(postdata, ur, user_id)
    index=0
    postdata.merge!({"userid" => user_id})
    if !ur.nil?
      ur.each do |k, v|
        postdata.merge!({"id#{index}" => v.id})
        postdata.merge!({"userid#{index}" => v.user_id})
        postdata.merge!({"roleid#{index}" => v.role_id})
        postdata.merge!({"isroleadmin#{index}" => v.is_role_admin})
        postdata.merge!({"canreadall#{index}" => v.can_read_all})
        postdata.merge!({"caninsertall#{index}" => v.can_insert_all})
        postdata.merge!({"canupdateall#{index}" => v.can_update_all})
        postdata.merge!({"candeleteall#{index}" => v.can_delete_all})
        index+=1
      end
    end
  end

  def self.make_user_roles(params_roles, user_id)
    return nil if params_roles.nil?
    user_roles = {}
    params_roles.each do |i, ur|
      user_role = UserRole.new
      user_role.id = ur['id']
      user_role.user_id = user_id
      user_role.role_id = ur['role_id']
      user_role.is_role_admin = ur['is_role_admin']
      user_role.can_read_all = ur['can_read_all']
      user_role.can_insert_all = ur['can_insert_all']
      user_role.can_update_all = ur['can_update_all']
      user_role.can_delete_all = ur['can_delete_all']
      user_roles.merge!({user_role.role_id => user_role})
    end
    return user_roles
  end

  def self.make_user(params_users, updated_user)
    updated_user.name = params_users[:name].nil? ? updated_user.name : params_users[:name]
    updated_user.password = params_users[:password].nil? ? updated_user.password : params_users[:password]
    updated_user.email = params_users[:email].nil? ? updated_user.email : params_users[:email]
    updated_user.is_active = params_users[:is_active].nil? ? updated_user.is_active : params_users[:is_active]
    updated_user.confirmed_password = params_users[:confirmed_password].nil? ? updated_user.confirmed_password : params_users[:confirmed_password]
    updated_user.timekeeper_id = params_users[:timekeeper_id].nil? ? updated_user.timekeeper_id : params_users[:timekeeper_id]

    return updated_user
  end

  def self.make_search_object(so, param_su)
    if so.nil?
      so = UserSearch.new
    end
    if !param_su.nil?
      so.role_id = param_su[:role].nil? ? '' : param_su[:role]
      so.is_active = param_su[:status].nil? ? '' : param_su[:status]
    end
    return so
  end
end