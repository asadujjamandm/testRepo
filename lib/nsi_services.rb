require 'utils'
module NsiServices
  def self.get(url, h, q=nil)
      h.merge!({NSI_DEVICE_KEY => NSI_DEVICE_VALUE})
      resp = HTTParty.get(NSI_SERVICE_URL + '/' + url, :headers => h, :query => q, :timeout => 60000)
      resp = resp.encode("utf-8", undef: :replace, replace: "??") #to make sure xml is in proper utf 8 format - Wasiq
      puts resp
      resp = Crack::XML.parse(resp)

      if !resp.nil? && !resp['returndata'].nil? && !resp['returndata']['errorcode'].nil?
        if resp['returndata']['errorcode'] == NSI_ERROR_NOT_AUTHORIZED
          raise Exceptions::ServiceNotAuthorized
        end
      end

      return resp
  end

  def self.hasPermission(url, h, q=nil)
    h.merge!({NSI_DEVICE_KEY => NSI_DEVICE_VALUE})
    resp = HTTParty.get(NSI_SERVICE_URL + '/' + url, :headers => h, :query => q, :timeout => 60000)
    resp = resp.encode("utf-8", undef: :replace, replace: "??") #to make sure xml is in proper utf 8 format - Wasiq
    resp = Crack::XML.parse(resp)

    if !resp.nil? && !resp['returndata'].nil? && !resp['returndata']['errorcode'].nil?
      if resp['returndata']['errorcode'] == NSI_ERROR_NOT_AUTHORIZED
        return false
      end
    end

    return true
  end

  def self.get_text(url, h, q=nil)
      h.merge!({NSI_DEVICE_KEY => NSI_DEVICE_VALUE})
      resp = HTTParty.get(NSI_SERVICE_URL + '/' + url, :headers => h, :query => q, :timeout => 60000)
      resp = resp.encode("utf-8", undef: :replace, replace: "??") #to make sure xml is in proper utf 8 format - Wasiq

      if resp.nil?
          raise Exceptions::ServiceNotAuthorized
      end

      return resp
  end

  #get only the text as it is not in an xml format
  #this method is not used now but kept for future if neeeded
  #def self.get_text(url, h, q=nil)
  #    h.merge!({NSI_DEVICE_KEY => NSI_DEVICE_VALUE})
  #    resp = HTTParty.get(NSI_SERVICE_URL + '/' + url, :headers => h, :query => q, :timeout => 60000)
  #    return resp.encode("utf-8", undef: :replace, replace: "??") #to make sure xml is in proper utf 8 format - Wasiq
  #end

  def self.post(url, h, q)
    h.merge!({NSI_DEVICE_KEY => NSI_DEVICE_VALUE})
    puts '-----------------------------------'
    puts 'URL: ' + url.to_s
    puts 'HEADER: ' + h.to_s
    puts 'QUERY: ' + q.to_s
    puts '-----------------------------------'
    resp = HTTParty.post(NSI_SERVICE_URL + '/' + url, :headers => h, :query => q, :timeout => 60000)
    resp = resp.encode("utf-8", undef: :replace, replace: "??") #to make sure xml is in proper utf 8 format - Wasiq
    resp = Crack::XML.parse(resp)

    if !resp.nil? && !resp['returndata'].nil? && !resp['returndata']['errorcode'].nil?
      if resp['returndata']['errorcode'] == NSI_ERROR_NOT_AUTHORIZED
        raise Exceptions::OperationNotAuthorized
      end
    end

    return resp
  end

  def self.delete(url, h, q)
    h.merge!({NSI_DEVICE_KEY => NSI_DEVICE_VALUE})
    resp = HTTParty.delete(NSI_SERVICE_URL + '/' + url, :headers => h, :query => q)
    resp = Crack::XML.parse(resp)

    if !resp.nil? && !resp['returndata'].nil? && !resp['returndata']['errorcode'].nil?
      if resp['returndata']['errorcode'] == NSI_ERROR_NOT_AUTHORIZED
        raise Exceptions::OperationNotAuthorized
      end
    end

    return resp
  end

  def self.get_auth(resp, l, p)
    return nil if resp.nil? || resp['returndata']['errorcode'] != NSI_AUTH_SUCCESS
    return Auth.new(:login => l, :password => p, :name => resp['returndata']['data'], :id => resp['returndata']['data_userid'])
  end

  def self.is_resp_success(resp)
    if resp.nil? || resp['returndata']['errorcode'] != NSI_ERROR_SUCCESS
      Utils.log( 'Response unsuccessful: ' + resp.to_s )
      return false
    end
    return true
  end

  def self.resp_message(resp)
    return GENERIC_ERROR_MESSAGE if resp.nil? || resp['returndata'].nil? || resp['returndata']['message'].nil? || resp['returndata']['message'] == ''
    return resp['returndata']['message']
  end

  def self.resp_success_with_code(resp)
    return false, resp['returndata']['errorcode'] if resp.nil? || resp['returndata']['errorcode'] != NSI_ERROR_SUCCESS
    return true, resp['returndata']['errorcode']
  end

  def self.resp_success_with_code_message(resp)
    return false, resp['returndata']['errorcode'], resp['returndata']['message'] if resp.nil? || resp['returndata']['errorcode'] != NSI_ERROR_SUCCESS
    return true, resp['returndata']['errorcode'], resp['returndata']['message']
  end

  def self.get_resp_return_data(resp)
    return nil if resp.nil? || resp['returndata']['data'].nil?
    return resp['returndata']['data']
  end

  def self.get_clients(resp)
    clients = {}
    return clients if resp.nil? || resp['clients'].nil?
    if resp['clients']['client'].is_a?(Array)
      resp['clients']['client'].each do |c|
        c_arr = c.split(',').collect! { |x| Utils.strip_str(x) }
        clients[c_arr[0]] = Client.get(c_arr)
      end
    else
      c_arr = resp['clients']['client'].split(',').collect! { |x| Utils.strip_str(x) }
      clients[c_arr[0]] = Client.get(c_arr)
    end
    return clients
  end

  def self.get_matters(resp)
    matters = {}
    return matters if resp.nil? || resp['matters'].nil?
    if resp['matters']['matter'].is_a?(Array)
      resp['matters']['matter'].each do |m|
        m_arr = m.split(',').collect! { |x| Utils.strip_str(x) }
        matters[m_arr[0]] = Matter.get(m_arr)
      end
    else
      m_arr = resp['matters']['matter'].split(',').collect! { |x| Utils.strip_str(x) }
      matters[m_arr[0]] = Matter.get(m_arr)
    end
    return matters
  end

  def self.get_autocomplete(resp)
    records = {}
    return records if resp.nil? || resp['Records'].nil?
    if resp['Records']['Record'].is_a?(Array)
      resp['Records']['Record'].each do |r|
        item = ListItem.get(r)
        records[ item.id ] = item
      end
    else
      item = ListItem.get( resp['Records']['Record'] )
      records[ item.id ] = item
    end
    return records
  end

  def self.get_timekeepers(resp)
    timekeepers = {}

    return timekeepers if resp.nil? || resp['timekeepers'].nil?

    if resp['timekeepers']['timekeeper'].is_a?(Array)
      resp['timekeepers']['timekeeper'].each do |t|
        t_arr = t.split(',').collect! { |x| Utils.strip_str(x) }
        timekeepers[t_arr[0]] = Timekeeper.get(t_arr)
      end
    else
      t_arr = resp['timekeepers']['timekeeper'].split(',').collect! { |x| Utils.strip_str(x) }
      timekeepers[t_arr[0]] = Timekeeper.get(t_arr)
    end

    return timekeepers
  end

  def self.get_registeredusers(resp)
    registeredusers = {}
    return registeredusers if resp.nil? || resp['registeredusers'].nil?
    if resp['registeredusers']['registereduser'].is_a?(Array)
      resp['registeredusers']['registereduser'].each do |r|
        r_arr = r.split(',').collect! { |x| Utils.strip_str(x) }
        registeredusers[r_arr[0]] = Register.get(r_arr)
      end
    else
      r_arr = resp['registeredusers']['registereduser'].split(',').collect! { |x| Utils.strip_str(x) }
      registeredusers[r_arr[0]] = Register.get(r_arr)
    end
    return registeredusers
  end
  def self.get_subscriptions(resp)
    submodels = {}
    return submodels if resp.nil? || resp['submodels'].nil?
    if resp['submodels']['submodel'].is_a?(Array)
      resp['submodels']['submodel'].each do |s|
        r_arr = s.split(',').collect! { |x| Utils.strip_str(x) }
        submodels[r_arr[0]] = SubscriptionModel.get(r_arr)
      end
    else
      r_arr = resp['submodels']['submodel'].split(',').collect! { |x| Utils.strip_str(x) }
      submodels[r_arr[0]] = SubscriptionModel.get(r_arr)
    end
    return submodels
  end

  def self.get_activitycodes(resp)
    activitycodes = {}
    return activitycodes if resp.nil? || resp['ActivityCodes'].nil?
    if resp['ActivityCodes']['ActivityCode'].is_a?(Array)
      resp['ActivityCodes']['ActivityCode'].each do |t|
        t_arr = t.split(',').collect! { |x| Utils.strip_str(x) }
        activitycodes[t_arr[0]] = Activitycode.get(t_arr)
      end
    else
      t_arr = resp['ActivityCodes']['ActivityCode'].split(',').collect! { |x| Utils.strip_str(x) }
      activitycodes[t_arr[0]] = Activitycode.get(t_arr)
    end
    return activitycodes
  end
  def self.get_timecards(resp)
    timecards = {}
    if ( resp.nil? ) || ( resp['timecards'].nil? )
      return timecards
    end
    if resp['timecards']['timecard'].is_a?(Array)
      resp['timecards']['timecard'].each do |t|
        t = t + ' '
        t_arr = t.split(',').collect! { |x| Utils.strip_str(x) }
        timecards[t_arr[0]] = Timecard.get(t_arr)
      end
    else
      t_arr = ( resp['timecards']['timecard'] + ' ' ).split(',').collect! { |x| Utils.strip_str(x) }
      timecards[t_arr[0]] = Timecard.get(t_arr)
    end
    return timecards
  end

  def self.get_paged_timecards(resp)
    timecards = {}
    if ( resp.nil? ) || ( resp['timecards'].nil? )|| ( resp['timecards']['totalRecords'].nil? )
      return timecards, 0, 0, 0
    elsif ( resp['timecards']['totalRecords'] == '0' )
      current_page = resp['timecards']['currentPage'].to_i
      total_records = resp['timecards']['totalRecords'].to_i
      page_size = resp['timecards']['pageSize'].to_i
      return timecards, current_page, total_records, page_size
    end
    if resp['timecards']['timecard'].is_a?(Array)
      resp['timecards']['timecard'].each do |t|
        t = t + ' '
        t_arr = t.split(',').collect! { |x| Utils.strip_str(x) }
        timecards[t_arr[0]] = Timecard.get(t_arr)
      end
    else
      t_arr = (resp['timecards']['timecard'] + ' ' ).split(',').collect! { |x| Utils.strip_str(x) }
      timecards[t_arr[0]] = Timecard.get(t_arr)
    end
    current_page = resp['timecards']['currentPage'].to_i
    total_records = resp['timecards']['totalRecords'].to_i
    page_size = resp['timecards']['pageSize'].to_i
    return timecards, current_page, total_records, page_size
  end

  def self.get_users(resp)
    users = {}
    return users if resp.nil? || resp['users'].nil?
    if resp['users']['user'].is_a?(Array)
      resp['users']['user'].each do |t|
        t_arr = t.split(',').collect! { |x| Utils.strip_str(x) }
        users[t_arr[0]] = User.get(t_arr)
      end
    else
      t_arr = resp['users']['user'].split(',').collect! { |x| Utils.strip_str(x) }
      users[t_arr[0]] = User.get(t_arr)
    end
    return users
  end

  def self.get_roles(resp)
    roles = {}
    return roles if resp.nil? || resp['roles'].nil?
    if resp['roles']['role'].is_a?(Array)
      resp['roles']['role'].each do |t|
        t_arr = t.split(',').collect! { |x| Utils.strip_str(x) }
        roles[t_arr[0]] = Role.get(t_arr)
      end
    else
      t_arr = resp['roles']['role'].split(',').collect! { |x| Utils.strip_str(x) }
      roles[t_arr[0]] = Role.get(t_arr)
    end
    return roles
  end

  def self.get_user_roles(resp)
    user_roles = {}
    return user_roles if resp.nil? || resp['userroles'].nil?
    if resp['userroles']['userrole'].is_a?(Array)
      resp['userroles']['userrole'].each do |t|
        t_arr = t.split(',').collect! { |x| Utils.strip_str(x) }
        user_roles[t_arr[0]] = UserRole.get(t_arr)
      end
    else
      t_arr = resp['userroles']['userrole'].split(',').collect! { |x| Utils.strip_str(x) }
      user_roles[t_arr[0]] = UserRole.get(t_arr)
    end
    return user_roles
  end

  def self.get_role_permissions(resp)
    role_permissions = {}
    return role_permissions if resp.nil? || resp['serviceobjectrolemappings'].nil?
    if resp['serviceobjectrolemappings']['serviceobjectrolemapping'].is_a?(Array)
      resp['serviceobjectrolemappings']['serviceobjectrolemapping'].each do |t|
        t_arr = t.split(',').collect! { |x| Utils.strip_str(x) }
        role_permissions[t_arr[0] + '_' + t_arr[1] + '_' + t_arr[2]] = RolePermission.get(t_arr)
      end
    else
      t_arr = resp['serviceobjectrolemappings']['serviceobjectrolemapping'].split(',').collect! { |x| Utils.strip_str(x) }
      role_permissions[t_arr[0] + '_' + t_arr[1] + '_' + t_arr[2]] = UserRole.get(t_arr)
    end
    return role_permissions
  end

  def self.get_user_settings(resp)
    user_settings = {}
    return user_settings if resp.nil? || resp['userSettings'].nil?
    if resp['userSettings']['userSetting'].is_a?(Array)
      resp['userSettings']['userSetting'].each do |t|
        t_arr = t.split(',').collect! { |x| Utils.strip_str(x) }
        user_settings[t_arr[0]] = UserSetting.get(t_arr)
      end
    else
      t_arr = resp['userSettings']['userSetting'].split(',').collect! { |x| Utils.strip_str(x) }
      user_settings[t_arr[0]] = UserSetting.get(t_arr)
    end
    return user_settings
  end


  def self.get_localized_data(resp)
    all_localized_data = {}
    return all_localized_data if resp.nil? || resp['allLocalizedData'].nil?

    if resp['allLocalizedData']['localizedData'].is_a?(Array)
      resp['allLocalizedData']['localizedData'].each do |t|
        t_arr = t.split(',').collect! { |x| Utils.strip_str(x) }
        all_localized_data[t_arr[0]] = LocalizedData.get(t_arr)
      end
    else
      t_arr = resp['allLocalizedData']['localizedData'].split(',').collect! { |x| Utils.strip_str(x) }
      all_localized_data[t_arr[0]] = LocalizedData.get(t_arr)
    end
    return all_localized_data
  end

  def self.get_user_locality_info(resp, id_only)

    locality_info = {}

    return locality_info if resp.nil? || resp['userLocality'].nil?

    if( id_only ) #if id only then
      return resp['userLocality']['localityID'], resp['userLocality']['dateFormatid'], resp['userLocality']['timeFormatid'] , resp['userLocality']['numberFormatid'] , resp['userLocality']['calendarStartDayid'], resp['userLocality']['timecardUnit']
    else
      return resp['userLocality']['localityID'], resp['userLocality']['dateFormat'], resp['userLocality']['timeFormat'] , resp['userLocality']['numberFormat'] , resp['userLocality']['calendarStartDay'], resp['userLocality']['timecardUnit']
    end

  end

  def self.get_date_format_list(resp)

    date_format_list = {}

    return date_format_list if resp.nil? || resp['dateFormats'].nil?

    if resp['dateFormats']['dateFormat'].is_a?(Array)
      resp['dateFormats']['dateFormat'].each do |t|
        date_format = DateFormat.get(t)
        date_format_list[ date_format.date_format_id ] = date_format
      end
    else
      date_format = DateFormat.get(resp['dateFormats']['dateFormat'])
      date_format_list[ date_format.date_format_id ] = date_format
    end

    return date_format_list

  end

   def self.get_time_format_list(resp)

    time_format_list = {}

    return time_format_list if resp.nil? || resp['timeFormats'].nil?

    if resp['timeFormats']['timeFormat'].is_a?(Array)
      resp['timeFormats']['timeFormat'].each do |t|
        time_format = TimeFormat.get(t)
        time_format_list[ time_format.time_format_id ] = time_format
      end
    else
      time_format = TimeFormat.get(resp['timeFormats']['timeFormat'])
      time_format_list[ time_format.time_format_id ] = time_format
    end

    return time_format_list

   end

   def self.get_number_format_list(resp)

    number_format_list = {}

    return number_format_list if resp.nil? || resp['numberFormats'].nil?

    if resp['numberFormats']['numberFormat'].is_a?(Array)
      resp['numberFormats']['numberFormat'].each do |t|
        number_format = NumberFormat.get(t)
        number_format_list[ number_format.number_format_id ] = number_format
      end
    else
      number_format = NumberFormat.get(resp['numberFormats']['numberFormat'])
      number_format_list[ number_format.number_format_id ] = number_format
    end

    return number_format_list

   end

  def self.get_locality_list(resp)

    locality_list = {}

    return locality_list if resp.nil? || resp['localities'].nil?

    if resp['localities']['locality'].is_a?(Array)
      resp['localities']['locality'].each do |t|
        locality = Locality.get(t)
        locality_list[ locality.locality_id ] = locality
      end
    else
      locality = Locality.get(resp['localities']['locality'])
      locality_list[ locality.locality_id ] = locality
    end

    return locality_list

  end

   def self.get_timecard_summary_list(resp)

    timecard_summary_list = {}

    return timecard_summary_list if resp.nil? || resp['timecardSummaries'].nil?

    if resp['timecardSummaries']['timecardSummary'].is_a?(Array)
      resp['timecardSummaries']['timecardSummary'].each do |t|
        got_date = t['billDate']
        posted = t['posted']
        billable = t['billStatus']
        total =  t['total'].to_f
        #added by akimul



        total_timecards = t['totalTimecards'].to_f
        total_posted = t['totalPosted'].to_f



        if timecard_summary_list[ got_date ].nil?
          timecard_summary_list[ got_date ] = {}
        end
        #added by akimul


        if timecard_summary_list[ got_date]["total_timecards"].nil?
          timecard_summary_list[ got_date]["total_timecards"]= total_timecards
        else
          timecard_summary_list[got_date]["total_timecards"] += total_timecards
        end
        if timecard_summary_list[got_date]["total_posted"].nil?
          timecard_summary_list[got_date]["total_posted"] = total_posted
        else
          timecard_summary_list[got_date]["total_posted"] += total_posted
        end


        #added by akimul

        if( timecard_summary_list[ got_date ][ posted ].nil? )
            timecard_summary_list[ got_date ][ posted ] =total
        else
            timecard_summary_list[ got_date ][ posted ] += total
        end
        if( timecard_summary_list[ got_date ][ billable ].nil? )
            timecard_summary_list[ got_date ][ billable ] = total
        else
            timecard_summary_list[ got_date ][ billable ] += total
        end
      end
    else
      t = resp['timecardSummaries']['timecardSummary']
      got_date = t['billDate']
      posted = t['posted']
      billable = t['billStatus']
      total =  t['total'].to_f
      #added by akimul



      total_timecards = t['totalTimecards'].to_f
      total_posted = t['totalPosted'].to_f


      if timecard_summary_list[ got_date ].nil?
        timecard_summary_list[ got_date ] = {}
      end
      #added by akimul


      if timecard_summary_list[ got_date]["total_timecards"].nil?
        timecard_summary_list[ got_date]["total_timecards"]= total_timecards
      else
        timecard_summary_list[got_date]["total_timecards"] += total_timecards
      end
      if timecard_summary_list[got_date]["total_posted"].nil?
        timecard_summary_list[got_date]["total_posted"] = total_posted
      else
        timecard_summary_list[got_date]["total_posted"] += total_posted
      end


      #added by akimul
      if( timecard_summary_list[ got_date ][ posted ].nil? )
          timecard_summary_list[ got_date ][ posted ] =total
      else
          timecard_summary_list[ got_date ][ posted ] += total
      end
      if( timecard_summary_list[ got_date ][ billable ].nil? )
          timecard_summary_list[ got_date ][ billable ] = total
      else
          timecard_summary_list[ got_date ][ billable ] += total
      end
    end

    return timecard_summary_list

   end

  #returns nil if no error
  def self.chek_if_timecard_editable(resp)

    if resp.nil? || resp['returndata'].nil? || resp['returndata']['data'].nil?
      return TIMECARD_NOT_EDITABLE_MESSAGE
    end

    if( resp['returndata']['data'] == 'erperror' || resp['returndata']['data'] == 'notfound'  || resp['returndata']['data'] == 'true' )
        return resp['returndata']['message']
    end

    return nil #nil means success

  end

  def self.get_erp_user(resp)

      if (resp['returndata']['data']=='erperror')
        return ''
      else
        if( resp['returndata']['data'] == 'null' )
          return ''
        else
          return resp['returndata']['data']
        end
      end

  end
  def self.get_farms_name(resp)

    if (resp['returndata']['data']=='erperror')
      return ''
    else
      if( resp['returndata']['data'] == 'null' )
        return ''
      else
        return resp['returndata']['data']
      end
    end

  end

  def self.get_erp_name(resp)

    erp_name = resp['erpsettings']['erp']
    mode = resp['erpsettings']['mode']

    return erp_name, mode

  end

  def self.get_timcard_persistent_days(resp)
    return nil if resp.nil? || resp['FarmSettings'].nil?

    if resp['FarmSettings']['FarmSetting'].is_a?(Array)
      resp['FarmSettings']['FarmSetting'].each do |t|
        farm_setting = FarmSetting.get(t)
      end
    else
      farm_setting_arr = resp['FarmSettings']['FarmSetting'].split(',').collect! { |x| Utils.strip_str(x) }
      farm_setting = FarmSetting.get(farm_setting_arr)
    end

    return farm_setting
  end
end