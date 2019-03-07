module ApplicationHelper
  def get_user_name
    if current_auth.nil?
      ''
    else
      current_auth.name.nil? || current_auth.name == '' ? current_auth.login : current_auth.name
    end
  end

  #gets the user name, if its bigger than 30 characters then remove extra character and place some ...
  def get_user_name_trimmed

    name =
      if current_auth.nil?
        ''
      else
        current_auth.name.nil? || current_auth.name == '' ? current_auth.login : current_auth.name
      end

    name = name[0,27] + '...' if name.length > 30

    return name
  end

  def get_tnb_user
    return session[SESSION_TNB_USER_ID]
  end

  def records_from
    (@start + 1).to_s
  end

  def records_to
    (@start + @page_results.count).to_s
  end

  def get_farm_name
    return session[SESSION_FARM_NAME]
  end

  def get_sync_enable
    return session[SESSION_SYNC_ENABLE]
  end
end