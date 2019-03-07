# updated by Wasiqul Islam at 24 May, 2011
# last updated by Wasiqul Islam at 16 June, 2011

class BaseController < LocalizationController
  def get_id
    session[:remember_token][SESSION_ID_INDEX]
  end

  def get_timecard_page_size
    session[SESSION_TIMECARD_PAGE_SIZE_KEY]
  end

  def get_timecard_report_page_size
    session[SESSION_TIMECARD_REPORT_PAGE_SIZE_KEY]
  end

  def get_user_page_size
    session[SESSION_USER_PAGE_SIZE_KEY]
  end

  def get_timekeeper_page_size
    session[SESSION_TIMEKEEPER_PAGE_SIZE_KEY]
  end

  def get_role_page_size
    session[SESSION_ROLE_PAGE_SIZE_KEY]
  end

  def set_user_settings
    begin
      session[SESSION_TIMECARD_PAGE_SIZE_KEY]        = TIMECARD_PAGE_SIZE
      session[SESSION_TIMECARD_REPORT_PAGE_SIZE_KEY] = TIMECARD_REPORT_PAGE_SIZE
      session[SESSION_USER_PAGE_SIZE_KEY]            = USER_PAGE_SIZE
      session[SESSION_ROLE_PAGE_SIZE_KEY]            = ROLE_PAGE_SIZE
      @user_settings = NsiServices.get_user_settings(NsiServices.get(NSI_SERVICE_USER_SETTING, {'userid' => get_login, 'password' => get_pwd}))
      session[SESSION_FARM_NAME]                     = NsiServices.get(NSI_SERVICE_FARMNAME, {'userid' => get_login, 'password' => get_pwd})['returndata']['farm_name']
      session[SESSION_SYNC_ENABLE]                   = NsiServices.get(NSI_SERVICE_FARMNAME, {'userid' => get_login, 'password' => get_pwd})['returndata']['farm_sync_enabled']
      # get the erp/tnb user id
      session[SESSION_TNB_USER_ID] = NsiServices.get_erp_user(NsiServices.get(NSI_SERVICE_ERP_USER, {'userid' => get_login, 'password' => get_pwd}))
      session[SESSION_USER_SUBSCRIPTION_REMAIN_DAYS_ERRORCODE] = NsiServices.get(NSI_SERVICE_USERSUB, {'userid' => get_login, 'password' => get_pwd, 'usersubcheckwebapp'=>'usersubcheckwebapp'})['returndata']['errorcode']
      session[SESSION_USER_SUBSCRIPTION_REMAIN_DAYS_MSG]       = NsiServices.get(NSI_SERVICE_USERSUB, {'userid' => get_login, 'password' => get_pwd, 'usersubcheckwebapp'=>'usersubcheckwebapp'})['returndata']['message']

      #session[SESSION_CUSTOMER_REF] =NsiServices.get_autocomplete( NsiServices.get(NSI_SERVICE_QBEXPORT, {'userid' => get_login, 'password' => get_pwd, 'report_type' => "request_qb_data_customer"}) )
      #session[SESSION_ITEM_REF]= NsiServices.get_autocomplete( NsiServices.get(NSI_SERVICE_QBEXPORT, {'userid' => get_login, 'password' => get_pwd, 'report_type' => "request_qb_data_item"}) )
      #session[SESSION_DEPT_REF] = NsiServices.get_autocomplete( NsiServices.get(NSI_SERVICE_QBEXPORT, {'userid' => get_login, 'password' => get_pwd, 'report_type' => "request_qb_data_dept"}) )
      #session[SESSION_CLASS_REF] = NsiServices.get_autocomplete( NsiServices.get(NSI_SERVICE_QBEXPORT, {'userid' => get_login, 'password' => get_pwd, 'report_type' => "request_qb_data_class"}) )


      @qb_settings = NsiServices.get_qb_settings(NsiServices.get(NSI_SERVICE_QBAUTH,{'userid' => get_login, 'password' => get_pwd, 'request_qb_auth'=>'request_qb_auth'}))
      @qb_settings.each do |k,v|
        session[SESSION_COMPANY_ID]   = v.company_id
        session[SESSION_CONSUMER_KEY] = v.consumer_token
        session[SESSION_CON_SECRET]   = v.consumer_token_secret
        session[SESSION_EXPIRE_DATE]  = v.access_token_expire_date
        puts session[SESSION_EXPIRE_DATE]
        puts session[SESSION_CONSUMER_KEY]
        puts session[SESSION_CON_SECRET]
      end
=begin
      @qb_settings = NsiServices.get_qb_settings(NsiServices.get(NSI_SERVICE_QBAUTH,{'userid' => get_login, 'password' => get_pwd, 'request_qb_auth'=>'request_qb_auth'}))

      @qb_settings.each do |k,v|
      company_id = v.company_id
      consumer_token = v.consumer_token
      consumer_token_request = v.consumer_token_secret
      e_date = v.access_token_expire_date
      oauth_token = v.oauth_token
      oauth_token_secret = v.oauth_token_secret
      relmId = v.realmId
      oauth_verifier =v.oauth_verifier
      session[SESSION_COMPANY_ID] = company_id
      session[SESSION_CONSUMER_KEY]=consumer_token
      session[SESSION_CONSUMER_SECRET]=consumer_token_request
      session[SESSION_EXPIRE_DATE] = e_date
      session[SESSION_OAUTH_TOKEN] = oauth_token
      session[SESSION_OAUTH_SECRET] = oauth_token_secret
      session[SESSION_RELMID] = relmId
      session[SESSION_OAUTH_VERIFIER] = oauth_verifier
        consumer_token = v.consumer_token
        consumer_token_request = v.consumer_token_secret
        session[SESSION_COMPANY_ID] = v.company_id
        session[CONSUMER_KEY] = consumer_token
        session[CON_SECRET] = consumer_token_request
        session[SESSION_EXPIRE_DATE] = v.access_token_expire_date
        oauth_token = v.oauth_token
        oauth_token_secret = v.oauth_token_secret
        relmId = v.realmId
        oauth_verifier =v.oauth_verifier
      puts session[SESSION_EXPIRE_DATE]
      puts session[SESSION_CONSUMER_KEY]
      puts session[SESSION_CONSUMER_SECRET]
      end
=end
      pageSize = 0
      @user_settings.each do |k, v|
        if v.setting_key == 'TIMECARD_PAGE_SIZE'
          pageSize = Integer( v.setting_value )
          if pageSize >= 1 && pageSize <= 1000
            session[SESSION_TIMECARD_PAGE_SIZE_KEY] = pageSize
          end
        end
        if v.setting_key == 'TIMECARD_REPORT_PAGE_SIZE'
          pageSize = Integer( v.setting_value )
          if pageSize >= 1 && pageSize <= 1000
            session[SESSION_TIMECARD_REPORT_PAGE_SIZE_KEY] = pageSize
          end
        end
        if v.setting_key == 'USER_PAGE_SIZE'
          pageSize = Integer( v.setting_value )
          if pageSize >= 1 && pageSize <= 1000
            session[SESSION_USER_PAGE_SIZE_KEY] = pageSize
          end
        end
        if v.setting_key == 'ROLE_PAGE_SIZE'
          pageSize = Integer( v.setting_value )
          if pageSize >= 1 && pageSize <= 1000
            session[SESSION_ROLE_PAGE_SIZE_KEY] = pageSize
          end
        end
      end
    rescue Exceptions::ServiceNotAuthorized => exception
      log_exception_text ( "User settings load fail: " + GENERIC_NON_AUTHORIZED_MESSAGE )
      flash.now[:fatalerror] = get_localized_text( GENERIC_NON_AUTHORIZED_MESSAGE , true )
      #if somehow load fails, do nothing(default is loaded already)
    rescue => e
      log_exception_text ( "User settings load fail: " + e.message )
      #if somehow load fails, do nothing(default is loaded already)
    end
  end


  def set_menu_labels
    @local_menu_labels = {}

    @local_menu_labels['change_password']        = get_localized_text('Change password', true)
    @local_menu_labels['sign_out']               = get_localized_text('Log out', true)
    @local_menu_labels['sign_in']                = get_localized_text('Log in', true)
    @local_menu_labels['home']                   = get_localized_text('Dashboard', true)
    @local_menu_labels['timecards']              = get_localized_text('Timecards', true)
    @local_menu_labels['new_timecard']           = get_localized_text('New Timecard', true)
    @local_menu_labels['synchronization']        = get_localized_text('Synchronization', true)
    @local_menu_labels['sync_timecard']          = get_localized_text('Sync Timecards', true)
    @local_menu_labels['sync_client']            = get_localized_text('Sync Clients', true)
    @local_menu_labels['sync_matter']            = get_localized_text('Sync Matters', true)
    @local_menu_labels['sync_timekeeper']        = get_localized_text('Sync Timekeepers', true)
    @local_menu_labels['sync_all']               = get_localized_text('Sync All', true)
    @local_menu_labels['user_and_role']          = get_localized_text('Users and Roles', true)
    @local_menu_labels['manage_users']           = get_localized_text('Manage Users', true)
    @local_menu_labels['manage_roles']           = get_localized_text('Manage Roles', true)
    @local_menu_labels['reports']                = get_localized_text('Reports', true)
    @local_menu_labels['search_timecards']       = get_localized_text('Search Timecards', true)
    @local_menu_labels['last_four_weeks']        = get_localized_text('Last Four Weeks', true)
    @local_menu_labels['month_to_date']          = get_localized_text('Month to Date', true)
    @local_menu_labels['year_to_date']           = get_localized_text('Year to Date', true)
    @local_menu_labels['settings']               = get_localized_text('Settings', true)
    @local_menu_labels['customize']              = get_localized_text('Customize', true)
    @local_menu_labels['change_password']        = get_localized_text('Change Password', true)
    @local_menu_labels['locale']                 = get_localized_text('Locale', true)
    @local_menu_labels['about']                  = get_localized_text('About', true)
    @local_menu_labels['about']                  = get_localized_text('About', true)
    @local_menu_labels['walkthroughs']           = get_localized_text('Walk-through', true)
    @local_menu_labels['blackberry_walkthrough'] = get_localized_text('Blackberry', true)
    @local_menu_labels['iphone_walkthrough']     = get_localized_text('iPhone', true)
    @local_menu_labels['android_walkthrough']    = get_localized_text('Android', true)
    @local_menu_labels['site_home']              = get_localized_text('Home', true)
    @local_menu_labels['farm_setting']           = get_localized_text('Firm Settings', true)
    @local_menu_labels['new_user']               = get_localized_text('New User', true)
    @local_menu_labels['new_role']               = get_localized_text('New Role', true)
    @local_menu_labels['show_timecards']         = get_localized_text('My Timecards', true)
    @local_menu_labels['sync_home']              = get_localized_text('Sync Home', true)
    @local_menu_labels['timecard_reports']       = get_localized_text('Timecard Reports', true)
    @local_menu_labels['user_settings']          = get_localized_text('User Settings', true)
    @local_menu_labels['users']                  = get_localized_text('Users', true)
    @local_menu_labels['roles']                  = get_localized_text('Roles', true)
    @local_menu_labels['activity_add']           = get_localized_text('Add Activity', true)
    @local_menu_labels['masters']                = get_localized_text('Master', true)
    @local_menu_labels['timekeepers']            = get_localized_text('Timekeeper', true)
    @local_menu_labels['clients']                = get_localized_text('Clients', true)
    @local_menu_labels['client']                 = get_localized_text('Client', true)
    @local_menu_labels['new_client']             = get_localized_text('New Client', true)
    @local_menu_labels['matter']                 = get_localized_text('Matter', true)
    @local_menu_labels['new_matter']             = get_localized_text('New Matter', true)
    @local_menu_labels['matters']                = get_localized_text('Matters', true)
    @local_menu_labels['activity_codes']         = get_localized_text('Activity', true)
    @local_menu_labels['user_master']            = get_localized_text('User', true)
    @local_menu_labels['list_timekeepers']       = get_localized_text('Timekeepers', true)
    @local_menu_labels['new_timekeeper']         = get_localized_text('New Timekeeper', true)
    @local_menu_labels['activities']             = get_localized_text('Activities', true)
    @local_menu_labels['new_activity']           = get_localized_text('New Activity', true)
    @local_menu_labels['preferences']            = get_localized_text('Preferences', true)
    @local_menu_labels['admins']                 = get_localized_text('Admin', true)
    @local_menu_labels['reg_users']              = get_localized_text('Registered Users', true)
    @local_menu_labels['subscribe']              = get_localized_text('Subscribe', true)
  end

  def get_months_start_and_end_date(system_date_time)
    # checking
    
    throw 'Invalid parameter, required DateTime' if system_date_time.nil? || !system_date_time.is_a?(DateTime)

    # TODO: Maybe refactor.

    start_date = DateTime.strptime( system_date_time.strftime('%Y-%m-') + '1', '%Y-%m-%d')
    end_date   = start_date.advance(months: 1)
    end_date   = end_date.advance(days: -1)

    [start_date, end_date]
  end

  # this method maybe used in home page and in a calendar report

  def generate_timecard_calendar_data(system_date_time)
    # checking
    
    # NOTE: Consider refactoring. Used twice now.

    throw 'Invalid parameter, required DateTime' if system_date_time.nil? || !system_date_time.is_a?(DateTime)
   

    # initialize instance variable and dates
    @calendar_info       = {}
    # @calendar_info['0'] = system_date_time.strftime( "%B, %Y" )
    @calendar_info['0']  = system_date_time.strftime('%B, %Y')
    start_date, end_date = get_months_start_and_end_date(system_date_time)

    # apply logic
    calendar_start_day = 1
    calendar_start_day = session['calendar_start_day']
    
    @array_of_days = %w(SUN MON TUE WED THU FRI SAT)
    
    if calendar_start_day == '1'
      @array_of_days = %w(SUN MON TUE WED THU FRI SAT)
    elsif calendar_start_day == '2'
      @array_of_days = %w(MON TUE WED THU FRI SAT SUN)
    elsif calendar_start_day == '3'
      @array_of_days = %w(TUE WED THU FRI SAT SUN MON)
    elsif calendar_start_day == '4'
      @array_of_days = %w(WED THU FRI SAT SUN MON TUE)
    elsif calendar_start_day == '5'
      @array_of_days = %w(THU FRI SAT SUN MON TUE WED)
    elsif calendar_start_day == '6'
      @array_of_days = %w(FRI SAT SUN MON TUE WED THU)
    elsif calendar_start_day == '7'
    end

    # changing from here, calander day sequence can be changed. this array sequence can even come from database if required(later) - Wasiq
    first_day = start_date.strftime('%a')
    first_day = first_day.upcase
    count     = 0
    
    7.times do |i|
      @array_of_days[i] == first_day ? break : count -= 1
    end
    # move the time backward as needed for the calendar component's first monday field
    # first monday(or sunday if calander is changed) of a calendar maynot be the 1st day of a month
    # if the first day is not the first day of the week, then move the date back to the first day of the week
    system_date_time = start_date.advance(days: count)

    # calculate calendar's' 6th row's visibility
    total_days_in_month  = Integer(end_date.advance(days: -1).strftime('%d'))
    
    @sixthRowsVisibility = if (total_days_in_month - count) > 35
                             '' # visible
                           else
                             'display:none' # invisible
                           end

    # main loop
    loop_count = 42 # there are at most 42 (6x7) fields in a calendar
    
    loop_count.times do |i|
      # this line is commented because, now all the calendar dates are shown event the previous or next month(if applicable)
      #         if( system_date_time >= start_date && system_date_time <= end_date )
      #           @calendar_info['' + (i+1).to_s ] = generate_single_calendar_cell_data( system_date_time )
      #         else
      #           @calendar_info['' + (i+1).to_s ] = generate_single_calendar_cell_data( nil )
      #         end

      # TODO: Rewrite this.

      if system_date_time >= start_date && system_date_time <= end_date
        @calendar_info['' + (i + 1).to_s] = generate_single_calendar_cell_data(system_date_time, true)
      else
        @calendar_info['' + (i + 1).to_s] = generate_single_calendar_cell_data(system_date_time, false)
      end

      system_date_time = system_date_time.advance(days: 1) # add 1 day along with the loop
    end
  end

  # this method may need to be overridden(in child class) to change functionality
  
  def generate_single_calendar_cell_data(date_time, _within_months_range)
    
    return '' if date_time.nil? # blank data
    
    # checking
    throw 'Invalid parameter, required DateTime' unless date_time.is_a?(DateTime)

    date_time.strftime('%d')
  end

  def load_timecard_calendar_data(system_date_time)
    # checking

    # TODO: Used a 3rd time. Should definitely be factored.

    
    throw 'Invalid parameter, required DateTime' if system_date_time.nil? || !system_date_time.is_a?(DateTime)

    # TODO: Probably turn into a class. start_date and end_date live together

    start_date, end_date = get_months_start_and_end_date(system_date_time)

    postdata = {}
    # finally get some more data, 7 days befor the start of the month, and 7 days after the end of the month
    start_date_tmp         = start_date.advance(days: -7)
    end_date_tmp           = end_date.advance(days: 7)
    postdata['from_date']  = start_date_tmp.strftime('%Y-%m-%d')
    postdata['to_date']    = end_date_tmp.strftime('%Y-%m-%d')
    postdata['is_monthly'] = true

    begin
     @timecard_calendar_data = NsiServices.get_timecard_summary_list(NsiServices.get(NSI_SERVICE_TIMECARD_SUMMARY, { 'userid' => get_login, 'password' => get_pwd }, postdata))
    rescue Exceptions::ServiceNotAuthorized => exception
     log_exception_text('Cannot get timecard summary: ' + GENERIC_NON_AUTHORIZED_MESSAGE)
     flash.now[:fatalerror]  = get_localized_text(GENERIC_NON_AUTHORIZED_MESSAGE, true)
     @timecard_calendar_data = {}
    rescue Exception => e
     log_exception_text('Cannot get timecard summary: ' + e.message)
     flash.now[:fatalerror]  = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
     @timecard_calendar_data = {}
    end
  end

  # TODO: Look into refactoring these.

  def get_single_calendar_data(key1, key2)
    if @timecard_calendar_data[key1].nil?
      return '0:00'
    elsif @timecard_calendar_data[key1][key2].nil?
      return '0:00'
    else
      return @timecard_calendar_data[key1][key2]
    end
  end

  # added by akimul
  def get_single_calendar_timecards(key1, key2)
    if @timecard_calendar_data[key1].nil?
      return 0.0
    elsif @timecard_calendar_data[key1][key2].nil?
      return 0.0
    else
      return @timecard_calendar_data[key1][key2]
    end
  end

  def has_timecard?(date_time_string)
    # if there is data in the hash, then there will be at least 1 timecard
    if @timecard_calendar_data[date_time_string].nil?
      return false
    else
      return true
    end
  end

end