module RegisterUtils
  def self.make_register_post_data(postdata, u)
    postdata.merge!({"id" => u.id})
    postdata.merge!({"full_name" => u.full_name})
    postdata.merge!({"email" => u.email})
    postdata.merge!({"password" => u.password})
    postdata.merge!({"confirmed_password" => u.confirmed_password})
    postdata.merge!({"farm_name" => u.farm_name})
  end


=begin
  def self.make_register_user(params_users, updated_user)
    updated_user.full_name = params_users[:full_name].nil? ? updated_user.full_name : params_users[:full_name]
    updated_user.password = params_users[:password].nil? ? updated_user.password : params_users[:password]
    updated_user.email = params_users[:email].nil? ? updated_user.email : params_users[:email]
    updated_user.is_active = params_users[:is_active].nil? ? updated_user.is_active : params_users[:is_active]
    updated_user.confirmed_password = params_users[:confirmed_password].nil? ? updated_user.confirmed_password : params_users[:confirmed_password]
    updated_user.farm_name = params_users[:farm_name].nil? ? updated_user.farm_name : params_users[:farm_name]

    return updated_user
  end
=end
end