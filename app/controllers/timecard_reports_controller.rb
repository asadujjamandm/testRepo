require 'nsi_services'
require 'timecard_utils'
require 'timecard_pdf_report'
require 'exceptions'
require 'utils'

class TimecardReportsController < BaseController
  before_filter :authenticate

  def index

    # TODO: Refact01

    if session[SESSION_USER_SUBSCRIPTION_REMAIN_DAYS_ERRORCODE].to_s == '8080'
      redirect_to('/subscriptions')
      return
    end
    #     set_view_properties 'All Timecards'
    #     query = {NSI_KEY_ISROLEBASEDQUERY => '1'}
    #     page_parameter = params[ 'page' ]
    #     if( page_parameter.nil? || page_parameter == '')
    #       page_parameter = '1'
    #     end
    #     query['current_page'] = page_parameter
    #     query['page_size'] = get_timecard_report_page_size
    #     get_timecards( query )
    #     #set_paginate

    @state    = 'search'
    from_date = get_localized_date(Utils.get_first_day_of_current_year)
    to_date   = get_localized_date(Utils.get_today)
    set_view_properties('Search Timecards')
    search_by_date(from_date, to_date)
  end

  def last_four_weeks
    @state    = 'last_four_weeks'
    from_date = get_localized_date(Utils.get_day_week_ago(4))
    to_date   = get_localized_date(Utils.get_today)
    # set_view_properties "Timecards of Last Four Weeks (#{from_date} - #{to_date})"
    set_view_properties('Timecards of Last Four Weeks')
    search_by_date(from_date, to_date)
  end

  def month_to_date
    @state    = 'month_to_date'
    from_date = get_localized_date(Utils.get_first_day_of_current_month)
    to_date   = get_localized_date(Utils.get_today)
    # set_view_properties "Timecards of This Month (#{from_date} - #{to_date})"
    set_view_properties('Timecards of This Month')
    search_by_date_no_render(from_date, to_date)
  end

  def year_to_date
    @state    = 'year_to_date'
    from_date = get_localized_date(Utils.get_first_day_of_current_year)
    to_date   = get_localized_date(Utils.get_today)
    # set_view_properties "Timecards of This Year (#{from_date} - #{to_date})"
    set_view_properties('Timecards of This Year')
    search_by_date(from_date, to_date)
  end

  def external_timecards_search
    @state    = 'monthly_report'
    from_date = get_localized_date(Date.strptime(params[:from_date]))
    to_date   = get_localized_date(Date.strptime(params[:to_date]))
    set_view_properties('Monthly Report')
    search_by_date(from_date, to_date)
  end

  def search
    @state = 'search'
    set_view_properties('Search Timecards')
    set_search(true, '')
    # set_paginate
    render 'index'
  end

  def view_pdf
    set_view_properties('View PDF')
    set_search_report(false, '')
    report            = TimecardPdfReport.new(@timecards, 'Admin', @localData)
    report.sub_header = get_localized_text(get_report_sub_header, true)
    send_data(report.create_report, type: 'application/pdf', disposition: 'inline', filename: 'TimecardReport.pdf')
  end

  def week_report
    set_view_properties('View PDF')
    set_search(false, 'pdf')
    report            = TimecardPdfReport.new(@timecards, 'Admin', @localData)
    report.sub_header = get_localized_text(get_report_sub_header, true)
    send_data(report.create_week_report, type: 'application/pdf', disposition: 'inline', filename: 'WeeklyReport.pdf')
  end

  def export_timecard_txt
    set_view_properties('Export')
    set_search(false, 'txt')
    send_data(@timecards_text, type: 'application/text', filename: 'Timecards_' + Time.now.to_s + '.txt')
  end

  def export_timecard_xml
    set_view_properties('Export')
    set_search(false, 'xml')
    send_data @timecards_text, type: 'application/text'
  end

  # def autocomplete_list
  #
  #  search_criteria = params["term"]
  #  extra_id = params["extra_id"]
  #  type = params["type"]
  #
  #  uid = get_login
  #  pwd = get_pwd
  #
  #  begin
  #    @records = get_autocomplete uid,pwd,type,search_criteria,extra_id
  #  rescue Exception => e
  #    log_exception_text ( "Autocomplete dropdown list for matter, client or timekeeper loading failed: " + e.message )
  #    throw "An error occured"
  #  end
  #
  #  render(:layout => false)    #layout false because its ajax
  #
  # end

  def calendar_view
    # this code is not used in the new version, so this action is removed from route file

    # TODO: Review this method.

    if session[:calendar_report_object].nil?
      @calendar_report_object                  = {}
      @calendar_report_object['report_date']   = DateTime.now
      @calendar_report_object['calendar_date'] = DateTime.now
      session[:calendar_report_object]         = @calendar_report_object
    else
      @calendar_report_object = session[:calendar_report_object]
    end

    unless params['report_date'].nil?
      report_date_parameter                  = params['report_date']
      @calendar_report_object['report_date'] = Date.strptime(report_date_parameter).to_datetime
    end

    unless params['calendar_date'].nil?
      calendar_date_parameter                  = params['calendar_date']
      @calendar_report_object['calendar_date'] = Date.strptime(calendar_date_parameter).to_datetime
    end

    @next_calendar_date     = @calendar_report_object['calendar_date'].advance(months: 1).strftime('%Y-%m-%d')
    @previous_calendar_date = @calendar_report_object['calendar_date'].advance(months: -1).strftime('%Y-%m-%d')
    @next_report_date       = @calendar_report_object['report_date'].advance(days: 1).strftime('%Y-%m-%d')
    @previous_report_date   = @calendar_report_object['report_date'].advance(days: -1).strftime('%Y-%m-%d')
    @date_for_pdf           = get_localized_date(@calendar_report_object['report_date'])

    set_view_properties('Calendar View ' + get_localized_date(@calendar_report_object['report_date']))
    
    @menu                 = 'timecard'
    @pageheader_image     = 'calendar.png'
    @selected_date_string = @calendar_report_object['report_date'].strftime('%Y-%m-%d')

    load_timecard_calendar_data(@calendar_report_object['calendar_date'])
    generate_timecard_calendar_data(@calendar_report_object['calendar_date'])

    @search_object   = TimecardUtils.make_search_object(nil, nil)
    @search_object.from_date = get_localized_date(@calendar_report_object['report_date'])
    @search_object.to_date   = get_localized_date(@calendar_report_object['report_date'])
    session[:search_object]  = @search_object

    # added to remove overloading error for search_timecards
    search_timecards(true, '')
    # search_timecards
    # set_paginate
    render 'calendar_view'
  end

  private

  def set_view_properties(title)
    @menu = 'report'
    
    # TODO: Rewrite

    if !params[:title].nil?
      @title      = get_localized_text(params[:title], true)
      @pageheader = get_localized_text(params[:title], true)
    else
      @title      = get_localized_text(title, true)
      @pageheader = get_localized_text(title, true)
    end

    @pageheader_image = 'report.png'
    set_menu_labels
    set_localization_texts
  end

  def get_non_paged_timecards(query, response_type)

    # TODO: Review this.
    
    if response_type == ''
      @timecards = NsiServices.get_timecards(NsiServices.get(NSI_SERVICE_TIMECARD_REPORT, { 'userid' => get_login, 'password' => get_pwd }, query))
      @timecards.each do |_k, v|
        v.template    = get_localized_text(v.template, true)
        v.description = get_localized_text(v.description, true)
        v.date        = get_localized_date(v.date.to_date)
        v.hhmm        = get_localized_time(('2000-01-01 ' + v.hhmm).to_datetime)
      end
    elsif response_type == 'txt'
      @timecards_text = NsiServices.get_text(NSI_SERVICE_TIMECARD_REPORT, { 'userid' => get_login, 'password' => get_pwd, 'report_type' => 'report_type_text' }, query)
    else
      # @timecards_text = NsiServices.get_text(NSI_SERVICE_TIMECARD_REPORT, {'userid' => get_login, 'password' => get_pwd, 'report_type' => 'report_type_text'}, query)
      @timecards_text = NsiServices.get_text(NSI_SERVICE_TIMECARD_REPORT, { 'userid' => get_login, 'password' => get_pwd, 'report_type' => 'report_type_xml', 'appinstance' => APP_INSTANCE }, query)
    end
  rescue Exceptions::ServiceNotAuthorized => exception
    log_exception_text('Timecard list load error: ' + GENERIC_NON_AUTHORIZED_MESSAGE)
    flash[:fatalerror] = get_localized_text(GENERIC_NON_AUTHORIZED_MESSAGE, true)
  rescue Exception => e
    log_exception_text('Timecard list load error: ' + e.message)
    flash[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
  end

  def get_timecards(query)
    @timecards, @current_page, @total_records, @page_size = NsiServices.get_paged_timecards(NsiServices.get(NSI_SERVICE_TIMECARD_REPORT, { 'userid' => get_login, 'password' => get_pwd }, query))
    
    # TODO: This is done twice. Review.

    @timecards.each do |_k, v|
      v.template    = get_localized_text(v.template, true)
      v.description = get_localized_text(v.description, true)
      v.date        = get_localized_date(v.date.to_date)
      v.hhmm        = get_localized_time(('2000-01-01 ' + v.hhmm).to_datetime)
    end
  rescue Exceptions::ServiceNotAuthorized => exception
    log_exception_text('Timecard list load error: ' + GENERIC_NON_AUTHORIZED_MESSAGE)
    flash[:fatalerror] = get_localized_text(GENERIC_NON_AUTHORIZED_MESSAGE, true)
  rescue Exception => e
    log_exception_text('Timecard list load error: ' + e.message)
    flash[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
  end

  def get_user_id(query)
    user_id = NsiServices.get_timekeepers(NsiServices.get(NSI_SERVICE_TIMEKEEPER, { 'userid' => get_login, 'password' => get_pwd, 'timekeepersearchlist' => 'timekeepersearchlist' }, 'TimekeeperNumber' => @search_object.timekeeper_number, 'DisplayName' => @search_object.timekeeper_name))

    temp = user_id.to_s

    temp = temp.slice(/timekeeper_number: "...."/)
  end

  def set_search
    set_search(true, '')
  end

  def set_search_report  ( is_paged, response_type )
    @search_object = TimecardUtils.make_search_object session[:search_object], @search_param
    @search_param  = params[:search_timecard]
    search_timecards(is_paged, response_type)
  end

  def set_search(is_paged, response_type)
    @search_object          = TimecardUtils.make_search_object(session[:search_object], params[:search_timecard])
    session[:search_object] = @search_object
    @search_param = params[:search_timecard]

    username = @search_object.timekeeper_name.to_s

    unless username == ''
      search_username
      session[:search_object].timekeeper = search_username.slice(/..\d\d/)
    end 

    search_timecards(is_paged, response_type)
  end

  def search_by_date(from_date, to_date)
    @search_object            = TimecardUtils.make_search_object(nil, nil)
    @search_object.from_date  = from_date
    @search_object.to_date    = to_date
    @search_object.date_range = from_date + ' - ' + to_date
    session[:search_object]   = @search_object
    search_timecards(true, '')
    # set_paginate
    render 'index'
  end

  def search_timecards(is_paged, response_type)
    @search_object = session[:search_object]

    # TODO: Review this.

    unless @search_object.nil?

      # apply localization
      if response_type == 'pdf'
        @search_object.from_date = get_date_as_string(get_localized_date(Date.today.at_beginning_of_month - 30))
        @search_object.to_date   = get_date_as_string(get_localized_date(Date.today.at_end_of_month - 30))        
        
        # TODO: Change this in production.

        #@search_object.from_date = get_date_as_string(get_localized_date(Utils.get_first_day_of_last_week))
        #@search_object.to_date   = get_date_as_string(get_localized_date(Utils.get_last_day_of_last_week))
      else
        @search_object.from_date = get_date_as_string(@search_object.from_date) unless @search_object.from_date.nil? || @search_object.from_date == ''
        @search_object.to_date   = get_date_as_string(@search_object.to_date)   unless @search_object.to_date.nil? || @search_object.to_date == ''
      end

      query, filtered_by = TimecardUtils.get_search_query(@search_object, method(:get_localized_date), method(:get_localized_text))

      if is_paged
        page_parameter        = params['page']
        page_parameter        = '1' if page_parameter.nil? || page_parameter == ''
        query['current_page'] = page_parameter
        query['page_size']    = get_timecard_report_page_size
      end

      # undo localization



      @search_object.from_date = get_localized_date(@search_object.from_date.to_date) unless @search_object.from_date.nil? || @search_object.from_date == ''
      @search_object.to_date   = get_localized_date(@search_object.to_date.to_date) unless @search_object.to_date.nil? || @search_object.to_date == ''


      # TODO: Rewrite this.
      response_type = '' if response_type == 'pdf'

      unless query.nil?
        query[NSI_KEY_ISROLEBASEDQUERY] = '1'
        if is_paged
          puts '----------------------------'
          puts 'SHOULD GO HERE'
          puts response_type
          puts '----------------------------'
          get_timecards(query)
        else
          get_non_paged_timecards(query, response_type)
        end
      end
    end
  end


  def search_username
    @search_object = session[:search_object]

    unless @search_object.nil?
      query, filtered_by = TimecardUtils.get_user_query(@search_object, method(:get_localized_text))
    end

    unless query.nil?
      return get_user_id(query)
    end

    return
  end

  # def get_autocomplete(uid, pwd, type, key, extra_id)
  #
  #  postdata = {}
  #  postdata.merge!({"type" => type})
  #  postdata.merge!({"key" => key})
  #  postdata.merge!({"extraId" => extra_id})
  #
  #  begin
  #    return NsiServices.get_autocomplete( NsiServices.get(NSI_SERVICE_AUTOCOMPLETE, {'userid' => uid, 'password' => pwd}, postdata) )
  #  rescue Exceptions::ServiceNotAuthorized => exception
  #    log_exception_text ( "Autocomplete load error: " + GENERIC_NON_AUTHORIZED_MESSAGE )
  #    flash.now[:fatalerror] = get_localized_text( GENERIC_NON_AUTHORIZED_MESSAGE , true )
  #    return {}
  #  rescue Exception=> e
  #    log_exception_text ( "Autocomplete load error: " + e.message )
  #    flash.now[:fatalerror] = get_localized_text( GENERIC_FATAL_ERROR_MESSAGE , true )
  #    return {}
  #  end
  # end
  #   def set_paginate
  #     @current_page = get_current_page
  #     if (!@timecards.nil?) && @timecards.count > 0
  #       @page_results = WillPaginate::Collection.create(@current_page, get_timecard_report_page_size, @timecards.count) do |pager|
  #         @start = (@current_page-1)*get_timecard_report_page_size
  #         pager.replace @timecards.to_a[@start, get_timecard_report_page_size]
  #       end
  #     end
  #   end

  def get_report_sub_header
    sub_header = ''

    # TODO: Review this method.
    
    if !@search_object.from_date.nil? && @search_object.from_date != ''
      if !@search_object.to_date.nil? && @search_object.to_date != ''
        sub_header = "date '#{@search_object.from_date}' to '#{@search_object.to_date}'"
      else
        sub_header = "date '#{@search_object.from_date}' to '#{Utils.get_today}'"
      end
    else
      if !@search_object.to_date.nil? && @search_object.to_date != ''
        sub_header = "As of '#{@search_object.to_date}'"
      end
    end

    if !@search_object.bill_status.nil? && @search_object.bill_status != ''
      sub_header += ', ' unless sub_header.empty?
      sub_header += @search_object.bill_status
    end

    if !@search_object.approved.nil? && @search_object.approved != ''
      sub_header += ', ' unless sub_header.empty?
      sub_header += @search_object.approved == 'Yes' ? 'Approved' : 'Not approved'
    end
    !sub_header.empty? ? '(Filtered by: ' + sub_header + ')' : ''
  end

  def get_current_page
    params[:page].nil? ? 1 : Integer(params[:page])
  end

  def set_localization_texts
    @localData = {}

    @localData['search']                               = get_localized_text('Search', true)
    @localData['search_timecards']                     = get_localized_text('Search timecards', true)
    @localData['view_pdf']                             = get_localized_text('View Pdf', true)
    @localData['week_report']                          = get_localized_text('Week Report', true)
    @localData['view_in_pdf_format']                   = get_localized_text('View in pdf format', true)
    @localData['view_report']                          = get_localized_text('View Report', true)
    @localData['bill_status']                          = get_localized_text('Bill Status', true)
    @localData['posted']                               = get_localized_text('Posted', true)
    @localData['from_date']                            = get_localized_text('From Date', true)
    @localData['to_date']                              = get_localized_text('To Date', true)
    @localData['matter']                               = get_localized_text('Matter', true)
    # @localData['template'] = get_localized_text( 'Template' , true )
    @localData['description']                          = get_localized_text('Narrative', true)
    @localData['internal_comment']                     = get_localized_text('Internal Comment', true)
    @localData['client']                               = get_localized_text('Client', true)
    @localData['timekeeper']                           = get_localized_text('Timekeeper', true)
    @localData['timekeeper_name']                      = get_localized_text('Timekeeper Name', true)
    @localData['work_hour']                            = get_localized_text('Work Hours', true)
    @localData['unit']                                 = get_localized_text('Unit', true)
    @localData['work_date']                            = get_localized_text('Work Date', true)
    @localData['bill_status']                          = get_localized_text('Bill Status', true)
    @localData['user']                                 = get_localized_text('User', true)
    @localData['status']                               = get_localized_text('Status', true)
    @localData['posted']                               = get_localized_text('Posted', true)
    @localData['timecard_is_posted']                   = get_localized_text('Timecard is posted', true)
    @localData['synced']                               = get_localized_text('Synced', true)
    @localData['timecard_is_synced']                   = get_localized_text('Timecard is synced', true)
    @localData['not_synced']                           = get_localized_text('Not synced', true)
    @localData['timecard_is_not_synced']               = get_localized_text('Timecard is cached', true)
    @localData['records']                              = get_localized_text('Records ', true)
    @localData['to']                                   = get_localized_text(' to ', true)
    @localData['total_records']                        = get_localized_text(' , total records ', true)
    @localData['timecard_report']                      = get_localized_text('Timecard Report', true)
    @localData['created_by']                           = get_localized_text('(Created by: ', true)
    @localData['total_bill_hours']                     = get_localized_text('Total bill hours: ', true)
    @localData['total_no_of_timecards']                = get_localized_text('Total no. of timecards: ', true)
    @localData['no_timecards_found_for_this_criteria'] = get_localized_text('No timecards found for this criteria', true)
    @localData['search_timecards']                     = get_localized_text('Search Timecards', true)
    @localData['billable']                             = get_localized_text('Billable', true)
    @localData['non_billable']                         = get_localized_text('Non-billable', true)
    # @localData['non_chargeable'] = get_localized_text( 'Non-chargeable' , true )
    @localData['yes']                                  = get_localized_text('Yes', true)
    @localData['no']                                   = get_localized_text('No', true)
    @localData['billable_non_billable']                = get_localized_text('Billable/Non-Billable', true)
    @localData['posted_not_posted']                    = get_localized_text('Posted/Pending', true)
    @localData['next']                                 = get_localized_text('Next', true)
    @localData['previous']                             = get_localized_text('Previous', true)
    # @localData['export_timecard'] = get_localized_text( 'Export' , true )
    @localData['export_timecard_txt']                  = get_localized_text('Export Text', true)
    @localData['export_timecard_xml']                  = get_localized_text('Export XML', true)
    @localData['date_range']                           = get_localized_text('Date Range', true)

  end

  # this method is overridden
  def generate_single_calendar_cell_data(date_time)
    
    if date_time.nil?
      hash1 = {}
      
      hash1['posted']       = ''
      hash1['billable']     = ''
      hash1['day']          = ''
      hash1['class']        = 'innertable'
      hash1['date']         = ''
      hash1['cell_visible'] = 'display:none;'
      
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

    hash1 = {}
    
    hash1['billable'] = billable + '/' + non_billable
    hash1['posted']   = posted + '/' + not_posted
    hash1['day']      = date_time.strftime('%d')

    hash1['class'] = if @selected_date_string == date_time_string
                       'currentselection'
                     elsif today_string == date_time_string
                       'today'
                     else
                       'innertable'
                     end

    hash1['date']         = date_time_string
    hash1['cell_visible'] = 'display:block;cursor:pointer;'

    hash1
  end
end
