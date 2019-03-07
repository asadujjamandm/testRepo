require 'exceptions'

class LocalityController < BaseController
  before_filter :authenticate

  include ActionView::Helpers::NumberHelper

  def index

    if session[SESSION_USER_SUBSCRIPTION_REMAIN_DAYS_ERRORCODE].to_s == '8080'
      redirect_to('/subscriptions')
      return
    end

    set_view_properties('Locale')
    fetch_all_data
    render 'index'
  end

  def fetch_all_data
    # build a special datetime that will have no ambiguity for the user
    # for example 27 cannot be a month etc.
    # 16 is a 24 hour format hour
    date1   = Time.now
    year    = date1.year.to_s
    date1   = (year + '/5/27 16:45:59').to_datetime
    # build a special number also
    number1 = 12_356_789.98

    # TODO: Look into those below.

    # get date format list
    date_format_list           = get_date_format_list
    @date_format_for_drop_down = []

    date_format_list.each do |_k, v|
      v.date_format = convert_date_time_format_to_ruby(v.date_format)
      v.date_format = date1.strftime(v.date_format)
      @date_format_for_drop_down.push(v)
    end

    # get time format list
    time_format_list           = get_time_format_list
    @time_format_for_drop_down = []

    time_format_list.each do |_k, v|
      v.time_format = convert_date_time_format_to_ruby(v.time_format)
      v.time_format = date1.strftime(v.time_format)
      @time_format_for_drop_down.push(v)
    end

    # get number format list
    number_format_list           = get_number_format_list
    @number_format_for_drop_down = []

    number_format_list.each do |_k, v|
      v.number_format = number_with_delimiter(number1, locale: v.number_format.to_sym)
      @number_format_for_drop_down.push(v)
    end

    # get locality list
    locality_list           = get_locality_list
    @locality_for_drop_down = []

    locality_list.each do |_k, v|
      @locality_for_drop_down.push(v)
    end

    # get calendar day list
    calendar_day_list                 = get_calendar_day_list
    @calendar_start_day_for_drop_down = []

    calendar_day_list.each do |_k, v|
      @calendar_start_day_for_drop_down.push(v)
    end

    @selected_timecard_unit = '60'

    # get user's locality
    begin
      @selected_locality, @selected_date_format, 
        @selected_time_format, @selected_number_format,
        @selected_calendar_start_day, @selected_timecard_unit = NsiServices.get_user_locality_info(NsiServices.get(NSI_SERVICE_USER_LOCALITY, 'userid' => get_login, 'password' => get_pwd), true)
    rescue Exceptions::ServiceNotAuthorized => exception
      log_exception_text('Localization data not loaded: ' + GENERIC_NON_AUTHORIZED_MESSAGE)
      flash.now[:fatalerror] = get_localized_text(GENERIC_NON_AUTHORIZED_MESSAGE, true)
      @selected_locality, @selected_date_format, @selected_time_format, @selected_number_format, @selected_calendar_start_day, @selected_timecard_unit = {}
    rescue Exception => e
      log_exception_text('Localization data not loaded: ' + e.message)
      flash.now[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
      @selected_locality, @selected_date_format, @selected_time_format, @selected_number_format, @selected_calendar_start_day, @selected_timecard_unit = {}
    end
  end

  def update

    # TODO: Look into rewriting an if statement like this.

    if params['locality'].nil?
      redirect_to action: 'index'
      return
    end

    post_data(params)
    set_view_properties('Locale')
    fetch_all_data
    render 'index'
  end

  def reset
    post_reset_command
    set_view_properties('Locale')
    fetch_all_data
    render 'index'
  end

  private

  def set_view_properties(title)
    @menu             = 'preference'
    @title            = get_localized_text(title, true)
    @pageheader       = get_localized_text(title, true)
    @pageheader_image = 'locale.png'
    @current_user_id  = get_id
    set_menu_labels
    set_localization_texts
  end

  def get_date_format_list
    return NsiServices.get_date_format_list(NsiServices.get(NSI_SERVICE_DATE_FORMAT, 'userid' => get_login, 'password' => get_pwd))
  rescue Exceptions::ServiceNotAuthorized => exception
    log_exception_text('Date format not loaded: ' + GENERIC_NON_AUTHORIZED_MESSAGE)
    flash.now[:fatalerror] = get_localized_text(GENERIC_NON_AUTHORIZED_MESSAGE, true)
    return {}
  rescue Exception => e
    log_exception_text('Date format not loaded: ' + e.message)
    flash.now[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
    return {}
  end

  def get_time_format_list
    return NsiServices.get_time_format_list(NsiServices.get(NSI_SERVICE_TIME_FORMAT, 'userid' => get_login, 'password' => get_pwd))
  rescue Exceptions::ServiceNotAuthorized => exception
    log_exception_text('Time format not loaded: ' + GENERIC_NON_AUTHORIZED_MESSAGE)
    flash.now[:fatalerror] = get_localized_text(GENERIC_NON_AUTHORIZED_MESSAGE, true)
    return {}
  rescue Exception => e
    log_exception_text('Time format not loaded: ' + e.message)
    flash.now[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
    return {}
  end

  def get_number_format_list
    return NsiServices.get_number_format_list(NsiServices.get(NSI_SERVICE_NUMBER_FORMAT, 'userid' => get_login, 'password' => get_pwd))
  rescue Exceptions::ServiceNotAuthorized => exception
    log_exception_text('Number format not loaded: ' + GENERIC_NON_AUTHORIZED_MESSAGE)
    flash.now[:fatalerror] = get_localized_text(GENERIC_NON_AUTHORIZED_MESSAGE, true)
    return {}
  rescue Exception => e
    log_exception_text('Number format not loaded: ' + e.message)
    flash.now[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
    return {}
  end

  def get_locality_list
    return NsiServices.get_locality_list(NsiServices.get(NSI_SERVICE_LOCALITY, 'userid' => get_login, 'password' => get_pwd))
  rescue Exceptions::ServiceNotAuthorized => exception
    log_exception_text('Locality data not loaded: ' + GENERIC_NON_AUTHORIZED_MESSAGE)
    flash.now[:fatalerror] = get_localized_text(GENERIC_NON_AUTHORIZED_MESSAGE, true)
    return {}
  rescue Exception => e
    log_exception_text('Locality data not loaded: ' + e.message)
    flash.now[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
    return {}
  end

  def get_calendar_day_list
    Utils.get_calendar_day_list
  end

  def post_data(inputData)
    postdata = {}
    make_post_data(postdata, inputData)

    resp = NsiServices.post(NSI_SERVICE_USER_LOCALITY, { 'userid' => get_login, 'password' => get_pwd }, postdata)
    
    # TODO: Look into this.

    if NsiServices.is_resp_success(resp)
      flash.now[:success] = get_localized_text(USER_LOCALITY_CHANGE_SUCCESS, true)
    else
      log('Locale not saved')
      flash.now[:error] = get_localized_text(USER_LOCALITY_CHANGE_ERROR, true)
    end
  rescue Exceptions::OperationNotAuthorized => exception
    log_exception_text('Locale not saved: ' + OPERATION_NON_AUTHORIZED_MESSAGE)
    flash.now[:fatalerror] = get_localized_text(OPERATION_NON_AUTHORIZED_MESSAGE, true)
  rescue Exception => e
    log_exception_text('Locale not saved: ' + e.message)
    flash.now[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
  end

  def post_reset_command
    postdata = {}
    
    postdata['reset'] = 'true'

    resp = NsiServices.post(NSI_SERVICE_USER_LOCALITY, { 'userid' => get_login, 'password' => get_pwd }, postdata)
    
    if NsiServices.is_resp_success(resp)
      flash.now[:success] = get_localized_text(USER_LOCALITY_RESET_SUCCESS, true)
    else
      log('Locale reset command failed')
      flash.now[:error] = get_localized_text(USER_LOCALITY_RESET_ERROR, true)
    end
   rescue Exceptions::OperationNotAuthorized => exception
     log_exception_text('Locale reset command failed: ' + OPERATION_NON_AUTHORIZED_MESSAGE)
     flash.now[:fatalerror] = get_localized_text(OPERATION_NON_AUTHORIZED_MESSAGE, true)
   rescue Exception => e
     log_exception_text('Locale reset command failed: ' + e.message)
     flash.now[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
   end

  def make_post_data(postdata, data)
    units     = data['timecard']['units']
    unit_type = data['timecard']['unit_type']
    seconds   = Utils.get_seconds_from_unit(units, unit_type)

    postdata['locality']           = data['locality']
    postdata['date_format']        = data['date_format']
    postdata['time_format']        = data['time_format']
    postdata['number_format']      = data['number_format']
    postdata['calendar_start_day'] = data['calendar_start_day']
    postdata.merge!('timecard_unit' => seconds.to_s)
  end

  def set_localization_texts
    @localData = {}

    @localData['change_user_locality'] = get_localized_text('Change User Locale', true)
    @localData['save_user_locality']   = get_localized_text('Save Locale', true)
    @localData['save']                 = get_localized_text('Save', true)
    @localData['reset_locality']       = get_localized_text('Reset Locale', true)
    @localData['reset_user_locality']  = get_localized_text('Reset', true)
    @localData['reset']                = get_localized_text('Reset', true)
    @localData['locale']               = get_localized_text('Locale', true)
    @localData['date_format']          = get_localized_text('Date Format', true)
    @localData['time_format']          = get_localized_text('Time Format', true)
    @localData['number_format']        = get_localized_text('Number Format', true)
    @localData['calendar_start_day']   = get_localized_text('Starting Day of Calendar View', true)
    @localData['timecard_unit']        = get_localized_text('Timecard Unit', true)
    @localData['change_notice']        = get_localized_text('(Changes on this page will take effect from your next login session)', true)
   end
end
