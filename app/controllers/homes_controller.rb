require 'utils'
require 'erp_sync'
require 'exceptions'

class HomesController < BaseController
  before_filter :authenticate
  include TimecardsHelper
  @total_tc = 0
  def index

    # TODO: Refact01

    if session[SESSION_USER_SUBSCRIPTION_REMAIN_DAYS_ERRORCODE].to_s == '8080'
      redirect_to('/subscriptions')
      return
    end

    set_view_properties('Dashboard')
    @dashboard = get_dashboard
    @state     = 'search'
    @state2    = 'ALL'

    # TODO: Take a look at this

    if session[:calendar_report_object].nil?
      @calendar_report_object = {}
      @calendar_report_object['report_date_from'] = DateTime.now
      @calendar_report_object['report_date_to']   = DateTime.now
      @calendar_report_object['calendar_date']    = DateTime.now
      session[:calendar_report_object] = @calendar_report_object
    else
      @calendar_report_object = session[:calendar_report_object]
    end

    # TODO: Can be refactored.

    if !params['calendar_date'].nil? && params['calendar_date'] != ''
      calendar_date_parameter = params['calendar_date']
      @calendar_report_object['calendar_date'] = Date.strptime(calendar_date_parameter).to_datetime
    end

    @next_calendar_date     = @calendar_report_object['calendar_date'].advance(months: 1).strftime('%Y-%m-%d')
    @previous_calendar_date = @calendar_report_object['calendar_date'].advance(months: -1).strftime('%Y-%m-%d')

    @selected_date_string = ''

    load_timecard_calendar_data(@calendar_report_object['calendar_date'])
    generate_timecard_calendar_data(@calendar_report_object['calendar_date'])

    # TODO: Review this.

    # apply localization for date/time format
    unless @dashboard.nil?
      date1 = nil
      unless @dashboard.last_login_web.nil?
        date1 = @dashboard.last_login_web.to_datetime
        unless date1.nil?
          # @dashboard.last_login_web = get_localized_date( date1 ) + ' ' + get_localized_time( date1 )
          @dashboard.last_login_web = get_localized_date(date1) + ' ' + get_localized_time_h_m(date1)
        end
      end
      unless @dashboard.last_sync_device.nil?
        date1 = @dashboard.last_sync_device.to_datetime
        unless date1.nil?
          # @dashboard.last_sync_device = get_localized_date( date1 ) + ' ' + get_localized_time( date1 )
          @dashboard.last_sync_device = get_localized_date(date1) + ' ' + get_localized_time_h_m(date1)
        end
      end
      # added by akimul
      unless @dashboard.last_time_card_date.nil?
        date1 = @dashboard.last_time_card_date.to_datetime
        unless date1.nil?
          # @dashboard.last_sync_device = get_localized_date( date1 ) + ' ' + get_localized_time( date1 )
          @dashboard.last_time_card_date = get_localized_date(date1)
        end
      end
      ####
      unless @dashboard.last_sync_web.nil?
        date1 = @dashboard.last_sync_web.to_datetime
        unless date1.nil?
          # @dashboard.last_sync_web = get_localized_date( date1 ) + ' ' + get_localized_time( date1 )
          @dashboard.last_sync_web = get_localized_date(date1) + ' ' + get_localized_time_h_m(date1)
        end
      end
      # last login device needs string operation
      unless @dashboard.last_login_device.nil?
        index = @dashboard.last_login_device.index(' (')
        unless index.nil?
          part1 = @dashboard.last_login_device[0, index]
          part2 = @dashboard.last_login_device[index, @dashboard.last_login_device.length - index]
          date1 = part1.to_datetime
          unless date1.nil?
            # @dashboard.last_login_device = get_localized_date( date1 ) + ' ' + get_localized_time( date1 ) + part2
            @dashboard.last_login_device = get_localized_date(date1) + ' ' + get_localized_time_h_m(date1)
          end
        end
      end
    end
  end

  def set_view_properties(title)
    @menu             = 'home'
    @title            = get_localized_text(title, true)
    @pageheader       = get_localized_text(title, true)
    @pageheader_image = 'home.png'
    set_menu_labels
    set_localization_texts
  end

  def set_localization_texts
    @localData = {}

    @localData['welcome']                    = get_localized_text('Welcome ', true)
    @localData['last_logged_in_at']          = get_localized_text('Last logged in at:', true)
    @localData['last_logged_in_from_device'] = get_localized_text('Last logged in from device at:', true)
    @localData['last_synced_from_device']    = get_localized_text('Last synced from device at:', true)
    @localData['last_synced_from_erp']       = get_localized_text('Last synced with ERP at:', true)
    @localData['you_have']                   = get_localized_text('You have ', true)
    @localData['timecards_of_this_month']    = get_localized_text('timecard(s) of this month', true)
    @localData['timecards_not_synced']       = get_localized_text('timecard(s) which are not synced', true)
    @localData['timecards_not_posted']       = get_localized_text('timecard(s) which are not posted', true)
    @localData['total_bill_hour_week']       = get_localized_text('Your total bill hours of this week: ', true)
    @localData['total_bill_hour_last_week']  = get_localized_text('Your total bill hours of last week: ', true)
    @localData['total_bill_hour_last_month'] = get_localized_text('Your total bill hours of this month: ', true)
    @localData['no_recent_timecard']         = get_localized_text('You have no recent timecard', true)
    @localData['see_recent_timecard']        = get_localized_text('See your recent timecards', true)
    @localData['billable_non_billable']      = get_localized_text('Billable/Non-Billable', true)
    @localData['posted_not_posted']          = get_localized_text('Posted/Pending', true)
    @localData['weekly_total']               = get_localized_text('Weekly Total', true)
    @localData['timecard_legend']            = get_localized_text('Timecard', true)
    @localData['last_time_entry_date']       = get_localized_text('Last timecard created For:', true)
  end

  # this method is overridden
  def generate_single_calendar_cell_data(date_time, within_months_range)

    # TODO: Look into.

    if date_time.nil?
      hash1 = {}
      
      hash1['posted']              = ''
      hash1['not_posted']          = ''
      hash1['billable']            = ''
      hash1['non_billable']        = ''
      hash1['day']                 = ''
      hash1['class']               = 'innertable'
      hash1['date']                = ''
      hash1['cell_visible']        = 'display:none;'
      hash1['has_timecard']        = false
      hash1['within_months_range'] = within_months_range
      hash1['total_timecards']     = ''
      hash1['tatal_posted']        = ''

      return hash1 # blank data
    end

    # checking
    throw 'Invalid parameter, required DateTime' unless date_time.is_a?(DateTime)

    date_time_string = date_time.strftime('%Y-%m-%d')
    today_string     = DateTime.now.strftime('%Y-%m-%d')
    billable         = get_single_calendar_data(date_time_string, 'billable')
    non_billable     = get_single_calendar_data(date_time_string, 'non_billable')
    posted           = get_single_calendar_data(date_time_string, 'posted')
    not_posted       = get_single_calendar_data(date_time_string, 'not_posted')
    total_timecards  = get_single_calendar_timecards(date_time_string, 'total_timecards')
    total_posted     = get_single_calendar_timecards(date_time_string, 'total_posted')

    # p total_timecards + " "+ total_posted+ " "

    has_timecard = has_timecard?(date_time_string)

    # if( billable == "0:00" && non_billable  == "0:00" && posted  == "0:00" && not_posted  == "0:00" )
    #  has_timecard = false
    # end

    hash1 = {}
    hash1['billable']        = billable
    hash1['non_billable']    = non_billable
    hash1['posted']          = posted
    hash1['not_posted']      = not_posted
    hash1['has_timecard']    = has_timecard
    hash1['day']             = date_time.strftime('%d')
    hash1['total_timecards'] = total_timecards
    hash1['total_posted']    = total_posted

    if @selected_date_string == (date_time_string + date_time_string) # from date, to date

      # TODO: Refactor

      if has_timecard
        hash1['class'] = 'innertablewithtimecard'
      else
        hash1['class'] = 'innertable' # note: this line is differant from timecardss page's generate_single_calendar_cell method
      end
    elsif today_string == date_time_string

      # TODO: Rewrite


      hash1['class'] = if has_timecard
                         'todaywithtimecard'
                       else
                         'today'
                       end
    else
      hash1['class'] = if has_timecard
                         'innertablewithtimecard'
                       else
                         'innertable'
                       end
    end

    hash1['date']                = get_localized_date(Date.strptime(date_time_string)) # note: this line is differant from timecardss page's generate_single_calendar_cell method
    hash1['cell_visible']        = 'display:block;cursor:pointer;'
    hash1['within_months_range'] = within_months_range

    hash1
  end

  private

  def get_dashboard
    resp = NsiServices.get(NSI_SERVICE_DASHBOARD, 'userid' => get_login, 'password' => get_pwd)
    return nil if resp.nil? || resp['dashboard'].nil?

    dashboard = Dashboard.new
    dashboard.last_login_web                 = resp['dashboard']['lastloginweb'].nil?              ? '' : Utils.strip_str(resp['dashboard']['lastloginweb'])
    dashboard.last_login_device              = resp['dashboard']['lastlogindevice'].nil?           ? '' : Utils.strip_str(resp['dashboard']['lastlogindevice'])
    dashboard.total_timecards                = resp['dashboard']['totaltimecards'].nil?            ? '' : Utils.strip_str(resp['dashboard']['totaltimecards'])
    dashboard.non_synced_timecards           = resp['dashboard']['nonsyncedtimecards'].nil?        ? '' : Utils.strip_str(resp['dashboard']['nonsyncedtimecards'])
    dashboard.non_approved_timecards         = resp['dashboard']['nonapprovedtimecards'].nil?      ? '' : Utils.strip_str(resp['dashboard']['nonapprovedtimecards'])
    dashboard.hours_this_week                = resp['dashboard']['thisweekhours'].nil?             ? '' : Utils.strip_str(resp['dashboard']['thisweekhours'])
    dashboard.hours_last_week                = resp['dashboard']['lastweekhours'].nil?             ? '' : Utils.strip_str(resp['dashboard']['lastweekhours'])
    dashboard.hours_this_month               = resp['dashboard']['thismonthhours'].nil?            ? '' : Utils.strip_str(resp['dashboard']['thismonthhours'])
    dashboard.total_billable_current         = resp['dashboard']['totalbillablecurrentmonth'].nil? ? '' : Utils.strip_str(resp['dashboard']['totalbillablecurrentmonth'])
    dashboard.total_non_billable_current     = resp['dashboard']['totalnbcurrentmonth'].nil?       ? '' : Utils.strip_str(resp['dashboard']['totalnbcurrentmonth'])
    dashboard.total_billable_last_month      = resp['dashboard']['totalbillablelastmonth'].nil?    ? '' : Utils.strip_str(resp['dashboard']['totalbillablelastmonth'])
    dashboard.total_non_billable_last_month  = resp['dashboard']['totalnblastmonth'].nil?          ? '' : Utils.strip_str(resp['dashboard']['totalnblastmonth'])
    dashboard.total_billable_last_month2     = resp['dashboard']['totalbillablelastmonth2'].nil?   ? '' : Utils.strip_str(resp['dashboard']['totalbillablelastmonth2'])
    dashboard.total_non_billable_last_month2 = resp['dashboard']['totalnblastmonth2'].nil?         ? '' : Utils.strip_str(resp['dashboard']['totalnblastmonth2'])
    dashboard.days_to_last_bill              = resp['dashboard']['daystolastbill'].nil?            ? '' : Utils.strip_str(resp['dashboard']['daystolastbill'])
    dashboard.last_time_card_date            = resp['dashboard']['lasttimeentrydate'].nil?         ? '' : Utils.strip_str(resp['dashboard']['lasttimeentrydate'])
    
    syncs                 = ErpSync.get_sync_status(get_login, get_pwd)
    web_sync, device_sync = ErpSync.get_recent_syncs(syncs)

    dashboard.last_sync_web    = web_sync.nil?    ? '' : web_sync.last_sync
    dashboard.last_sync_device = device_sync.nil? ? '' : device_sync.last_sync

    return dashboard
  rescue Exceptions::ServiceNotAuthorized => exception
    log_exception_text('Dashboard not loaded: ' + GENERIC_NON_AUTHORIZED_MESSAGE)
    flash.now[:fatalerror] = get_localized_text(GENERIC_NON_AUTHORIZED_MESSAGE, true)
    return nil
  rescue Exception => e
    log_exception_text('Dashboard not loaded: ' + e.message)
    flash.now[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
    return nil
  end
end
