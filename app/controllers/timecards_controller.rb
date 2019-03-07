require 'nsi_services'
require 'timecard_utils'
require 'exceptions'

class TimecardsController < TimecardsBaseController
  before_filter :authenticate
  @page_id = '1'



  def index
    #     if (session[SESSION_USER_SUBSCRIPTION_REMAIN_DAYS_ERRORCODE].to_s == '8080')
    #       redirect_to("/subscriptions")
    #       return
    #     end

    @state  = get_state # if state is 'search' then search boxes are shown, else not
    @state2 = get_state
    set_view_properties('Timecards')
    a_title = 'Timecards'
    set_view_properties(a_title)
    clear_search
    today_search
    calendar_view
  end

  def calendar_view
    @state  = 'calendar'
    @state2 = get_state2

    # session[:calendar_report_object] = nil
    set_view_properties('Timecards')
    @menu             = 'timecard'
    @pageheader_image = 'calendar.png'
    @search_object    = session[:search_object]

    # TODO: Review this. All of this.

    if !@search_object.nil?
      @calendar_report_object = {}

      if @search_object.from_date.nil? || @search_object.from_date == '' || @search_object.to_date.nil? || @search_object.to_date == ''
        @calendar_report_object['report_date_from'] = DateTime.now
        @calendar_report_object['report_date_to']   = DateTime.now
        @calendar_report_object['calendar_date']    = DateTime.now
      else
        @calendar_report_object['report_date_from'] = DateTime.strptime(get_date_as_string(@search_object.from_date), '%Y-%m-%d')
        @calendar_report_object['report_date_to']   = DateTime.strptime(get_date_as_string(@search_object.to_date), '%Y-%m-%d')
        @calendar_report_object['calendar_date']    = DateTime.strptime(get_date_as_string(@search_object.from_date), '%Y-%m-%d')
      end
      session[:calendar_report_object] = @calendar_report_object
    elsif session[:calendar_report_object].nil?
      @calendar_report_object = {}
      @calendar_report_object['report_date_from'] = DateTime.now
      @calendar_report_object['report_date_to']   = DateTime.now
      @calendar_report_object['calendar_date']    = DateTime.now
      session[:calendar_report_object] = @calendar_report_object
    else
      @calendar_report_object = session[:calendar_report_object]
    end

    if !params['report_date_from'].nil? && params['report_date_from'] != ''
      report_date_parameter = params['report_date_from']
      @calendar_report_object['report_date_from'] = Date.strptime(report_date_parameter).to_datetime
    end

    if !params['report_date_to'].nil? && params['report_date_to'] != ''
      report_date_parameter = params['report_date_to']
      @calendar_report_object['report_date_to'] = Date.strptime(report_date_parameter).to_datetime
    end

    if !params['calendar_date'].nil? && params['calendar_date'] != ''
      calendar_date_parameter = params['calendar_date']
      @calendar_report_object['calendar_date'] = Date.strptime(calendar_date_parameter).to_datetime
    end

    @next_calendar_date     = @calendar_report_object['calendar_date'].advance(months: 1).strftime('%Y-%m-%d')
    @previous_calendar_date = @calendar_report_object['calendar_date'].advance(months: -1).strftime('%Y-%m-%d')
    @next_report_date       = @calendar_report_object['report_date_to'].advance(days: 1).strftime('%Y-%m-%d')
    @previous_report_date   = @calendar_report_object['report_date_from'].advance(days: -1).strftime('%Y-%m-%d')

    @selected_date_string = @calendar_report_object['report_date_from'].strftime('%Y-%m-%d') +
                            @calendar_report_object['report_date_to'].strftime('%Y-%m-%d')

    load_timecard_calendar_data(@calendar_report_object['calendar_date'])
    generate_timecard_calendar_data(@calendar_report_object['calendar_date'])

    search_params = {}
    
    search_params[:from_date]  = get_localized_date(@calendar_report_object['report_date_from'])
    search_params[:to_date]    = get_localized_date(@calendar_report_object['report_date_to'])
    search_params[:additional] = get_state2
    @search_object     = TimecardUtils.make_search_object(session[:search_object], search_params)
    session[:search_object]    = @search_object
    search_timecards
    
    render 'index'
  end

  def new
    #     if (session[SESSION_USER_SUBSCRIPTION_REMAIN_DAYS_ERRORCODE].to_s == '8080')
    #       redirect_to("/subscriptions")
    #       return
    #     end

    @state   = 'new'
    @state2  = get_state2
    clear_updated_timecards
    @page_id = '1'

    # TODO: Review this.

    new_timecard = if session[:cached_timecard]
                     session[:cached_timecard]
                   else
                     Timecard.new
                   end

    # set date as the calendar is selected
    
    # TODO: Review this.

    if is_calendar_selected
      calendar_report_object = session[:calendar_report_object]
      new_timecard.date      = get_localized_date(calendar_report_object['report_date_from'])
    else
      new_timecard.date = get_localized_date(Date.today)
    end

    # set the default unit for the new timecard
    new_timecard.units = (session['timecard_unit'].nil? ? '60' : session['timecard_unit'])

    render_new new_timecard
  end

  def new_activity
    @state  = 'add_activity' # if state is 'search' then search boxes are shown, else not
    @state2 = get_state2
    set_view_properties('Add Daily Activity')
    a_title = 'Add Daily Activity'
    set_view_properties(a_title)
    # render_add

    # TODO: Rewrite.

    new_timecard = if session[:cached_timecard]
                     session[:cached_timecard]
                   else
                     Timecard.new
                   end

    render_add new_timecard
  end

  def create
    @state       = 'new'
    @state2      = get_state2
    clear_updated_timecards
    @page_id     = '1'
    new_timecard = TimecardUtils.make_timecard(@timecards, params[:timecard], get_id, nil)
    message = new_timecard.validate(session['date_format'])
   
    # changed due to new requirement to create billable activity from timecard creation page
    #     if message == '' #if no validation error then check for this validation
    #       message = validate_timecard_bill_status  new_timecard
    #     end
    
    if message == ''
      post_timecard(new_timecard, params[:timecard][:finalized])
      redirect_to action: 'new'
    else
      flash.now[:notice] = get_localized_text('Following field(s) are required and should be valid: ' + message, true)
      render_new new_timecard
    end
  end

  def edit

    if params[:timecard].nil?
      redirect_to action: 'index'
      return
    end

    @page_id       = '2'
    is_new         = (params[:timecard][:is_new].nil? ? false : (params[:timecard][:is_new] == 'true' ? true : false))
    @state         = get_state
    @state2        = get_state2
    @search_object = session[:search_object]
    set_view_properties('')
    search_timecards
    set_view_properties('Edit Timecard')
    get_updated_timecards
    updated_timecard = TimecardUtils.make_timecard(@timecards, params[:timecard], get_id, @updated_timecards)

    # TODO: Look into this.

    if !updated_timecard.nil?

      message = ''
      message = updated_timecard.validate(session['date_format']) unless is_new
      if message == ''
        get_dirty_timecard

        set_updated_timecard(updated_timecard) unless is_new

        # check if the timecard is editable
        editable = is_timecard_editable(@dirty_timecard, true)

        unless editable
          @dirty_timecard = nil
          select_first_timecard_from_the_updated_timecard_list
          render_index
          return
        end

      else
        flash.now[:notice] = get_localized_text('Following field(s) are required and should be valid: ' + message, true)
        @dirty_timecard    = undo_dirty_confirm(updated_timecard)
      end

    else

      get_dirty_timecard
      # set_updated_timecard @dirty_timecard

      # check if the timecard is editable
      editable = is_timecard_editable(@dirty_timecard, true)

      # TODO: Look into this.

      unless editable
        @dirty_timecard = nil
        render_index
        return
      end

    end

    # render_index
    render 'new'
  end

  def update
    @state         = get_state
    @state2        = get_state2
    @search_object = session[:search_object]
    @page_id       = '3'
    set_view_properties('')
    search_timecards
    set_view_properties('Edit Timecard')
    get_updated_timecards
    updated_timecard = TimecardUtils.make_timecard(@timecards, params[:timecard], get_id, @updated_timecards)
    message = updated_timecard.validate(session['date_format'])
    # changed due to new requirement to create billable activity from timecard creation page
    #     if message == '' #if no validation error then check for this validation
    #       message = validate_timecard_bill_status  updated_timecard
    #     end

    # TODO: Review this.

    if message == ''

      finalized = params[:timecard][:finalized]

      if finalized == 'true' # if post
        success = post_timecard(updated_timecard, finalized)
        # flash[:error] = get_localized_text( "test error" , true )
        if success
          # delete the timecard from pending list that is just posted
          @updated_timecards.delete('' + updated_timecard.id)
          select_first_timecard_from_the_updated_timecard_list
        else
          set_updated_timecard(updated_timecard)
          @dirty_timecard = updated_timecard
        end
        @state = 'normal'
        search_timecards # needed
        render_index
      else # if not post, only update
        set_updated_timecard(updated_timecard)
        post_timecards
        # search_timecards
        @state = 'normal'
        redirect_to action: 'search', page: get_current_page
        #redirect_to action: 'index'
      end

    else
      flash.now[:notice] = get_localized_text('Following field(s) are required and should be valid: ' + message, true)
      @dirty_timecard    = undo_dirty_confirm updated_timecard
      render_index
    end
  end

  def delete
    @state  = get_state
    @state2 = get_state2
    set_view_properties('')

    # make a blank timecard
    timecard          = Timecard.new
    timecard.id       = params[:timecard_id]
    timecard.approved = params[:timecard_approved]
    timecard.posted   = params[:timecard_posted]
    # check if the timecard is editable
    editable = is_timecard_editable(timecard, false)

    delete_timecard(params[:timecard_id]) if editable
    redirect_to action: 'search', page: get_current_page
  end

  # TODO: refactor the search. make some view to handle the query
  def search
      @state  = get_state
    @state2 = get_state2
    clear_updated_timecards
    set_view_properties('Timecards')
    @search_object = TimecardUtils.make_search_object(session[:search_object], params[:search_timecard])

    if !@search_object.from_date.nil? && !@search_object.to_date.nil? && @search_object.from_date != '' && @search_object.to_date != ''
      # set calendar object
      @calendar_report_object = {}
      
      @calendar_report_object['report_date_from'] = DateTime.strptime(get_date_as_string(@search_object.from_date), '%Y-%m-%d')
      @calendar_report_object['report_date_to']   = DateTime.strptime(get_date_as_string(@search_object.to_date), '%Y-%m-%d')
      @calendar_report_object['calendar_date']    = DateTime.strptime(get_date_as_string(@search_object.from_date), '%Y-%m-%d')
      session[:calendar_report_object] = @calendar_report_object
    end

    render_search
  end

  def external_search
    clear_updated_timecards
    @state  = get_state
    @state2 = params[:state2]

    # TODO: Rewrite this.

    @state2 = if !@state2.nil?
                @state2.to_s.upcase
              else
                'ALL'
              end
    set_view_properties('Timecards')
    search_params = {}
    
    search_params[:approved]   = params[:search_timecard_approved]
    search_params[:synced]     = params[:search_timecard_synced]
    search_params[:from_date]  = params[:search_timecard_from_date]
    search_params[:to_date]    = params[:search_timecard_to_date]
    search_params[:additional] = @state2

    # TODO: Review

    unless search_params[:from_date].nil? || search_params[:from_date] == ''
      begin
        search_params[:from_date] = get_localized_date(Date.strptime(search_params[:from_date]))
        search_params[:to_date]   = get_localized_date(Date.strptime(search_params[:to_date]))
      rescue Exception => e
        log_exception_text('External timecard search failed: ' + e.message)
        search_params[:from_date] = DateTime.now
        search_params[:to_date]   = DateTime.now
      end
    end
    @search_object = TimecardUtils.make_search_object(session[:search_object], search_params)
    render_search
  end

  def cancel
    redirect_to action: 'search', page: get_current_page
  end

  # for submitting temporary matter
  def temporary_matter
    post_temp_matter

    render(layout: false) # layout false because its ajax
  end

  # this method will not be used any longer
  def matter_bill_status
    @error    = ''
    matter_id = '' + params['matter_id']
    uid       = get_login
    pwd       = get_pwd

    begin
      get_matter(uid, pwd, matter_id)
    rescue Exception => e
      log_exception_text('Unable to load matter bill status: ' + e.message)
      @error = '##error**'
    end

    render(layout: false)    # layout false because its ajax
  end

  def autocomplete_list
    search_criteria = params['term']
    extra_id        = params['extra_id']
    type            = params['type']
    uid             = get_login
    pwd             = get_pwd

    begin
      @records = get_autocomplete(uid, pwd, type, search_criteria, extra_id)
      puts @records
    rescue Exception => e
      log_exception_text('Autocomplete dropdown list for matter, client or timekeeper loading failed: ' + e.message)
      throw 'An error occured'
    end

    render(layout: false)    # layout false because its ajax
  end

  def timecard_list
    date = params['date']
    # date="11-14-2014"
    set_view_properties('Timecards')
    a_title = 'Timecards'
    set_view_properties(a_title)

    begin
      search_params              = {}
      from_date                  = Date.strptime(date, '%m-%d-%Y')
      to_date                    = from_date
      search_params[:from_date]  = from_date.strftime('%m-%d-%Y')
      search_params[:to_date]    =  to_date.strftime('%m-%d-%Y')
      search_params[:additional] = get_state2

      puts session[:search_object]

      @search_object     = TimecardUtils.make_search_object(session[:search_object], search_params)
      session[:search_object]    = @search_object
      search_timecards
      puts @timecards
      @records = @timecards
    rescue Exception => e
      log_exception_text('Time Card List loading failed: ' + e.message)
      throw 'An error occured'
    end
    render(layout: false) # layout false because its ajax
  end

  private

  # check if the timecard is editable
  def is_timecard_editable(timecard, is_edit_mode) # edit mode or delete mode
    editable = true

    # TODO: Review this whole method.

    if timecard.approved == 'yes'
      if is_edit_mode
        flash.now[:error] = get_localized_text('Unable to edit because: The timecard is finalized', true)
      else
        flash[:error] = get_localized_text('Unable to delete because: The timecard is finalized', true)
      end
      editable = false
    elsif timecard.posted != 'yes' && timecard.approved != 'yes'
      editable = true
    else
      begin
        error_message = NsiServices.chek_if_timecard_editable(NsiServices.get(NSI_SERVICE_TIMECARD_STATUS, 'userid' => get_login, 'password' => get_pwd, 'id' => timecard.id))
      rescue Exceptions::ServiceNotAuthorized => exception
        log_exception_text('Timecard status load error: ' + GENERIC_NON_AUTHORIZED_MESSAGE)
        flash.now[:fatalerror] = get_localized_text(GENERIC_NON_AUTHORIZED_MESSAGE, true)
        error_message = GENERIC_NON_AUTHORIZED_MESSAGE
      rescue Exception => e
        log_exception_text('Timecard status load error: ' + e.message)
        flash.now[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
        error_message = GENERIC_NON_AUTHORIZED_MESSAGE
      end

      if error_message.nil?
        editable = true
      else
        if is_edit_mode
          flash.now[:error] = get_localized_text('Unable to edit because: ' + error_message, true)
        else
          flash[:error] = get_localized_text('Unable to delete because: ' + error_message, true)
        end
        editable = false
      end
    end

    editable
  end

  def select_first_timecard_from_the_updated_timecard_list
    updated_timecard = nil
    
    # TODO: Review this.

    if @updated_timecards.size >= 1
      @updated_timecards.each do |_k, v| # loop for once only
        updated_timecard = v
        @dirty_timecard  = v
        break
      end
      
      set_updated_timecard updated_timecard
    end
  end

  def get_state

    # TODO: Can be rewritten.

    if params['state'].nil?
      return 'normal'
    else
      return params['state']
    end
  end

  def get_state2

    # TODO: Rewrite.

    if params[:search_timecard].nil?
      if !params[:state2].nil?
        return params[:state2].to_s.upcase
      else
        return 'ALL'
      end
    end

    return 'ALL' if params[:search_timecard][:additional].nil?

    params[:search_timecard][:additional]
  end

  def today_search
    if is_calendar_selected
      if session[:search_object].nil?
        search_params = {}

        calendar_report_object    = session[:calendar_report_object]
        search_params[:from_date] = get_localized_date(calendar_report_object['report_date_from'])
        search_params[:to_date]   = get_localized_date(calendar_report_object['report_date_from'])
        @search_object    = TimecardUtils.make_search_object(session[:search_object], search_params)
        session[:search_object]   = @search_object
      end
    else
      search_params = {}
      search_params[:from_date] = get_localized_date(Date.today)
      search_params[:to_date]   = get_localized_date(Date.today)
      @search_object    = TimecardUtils.make_search_object(session[:search_object], search_params)
      session[:search_object]   = @search_object
    end
    search_timecards
  end

  def set_view_properties(title)
    @menu             = 'timecard'
    @title            = get_localized_text(title, true)
    @pageheader       = get_localized_text(title, true)
    @pageheader_image = 'timecard.png'
    set_menu_labels
    set_localization_texts
  end

  def render_index
    # set_paginate
    #render :index
    redirect_to action: "index"
  end

  def render_search
    session[:search_object] = @search_object
    search_timecards
    render_index
  end

  def clear_search
    session.delete :search_object
  end

  def render_new(timecard)
    set_view_properties('Timecard')
    @dirty_timecard = timecard
    today_search
    set_view_properties('New Timecard')
    # render_index
    render 'new'
  end

  def render_add(timecard)
    set_view_properties('Add Daily Activity')
    @dirty_timecard = timecard
    render 'timecards/_add_activity'
  end

  def undo_dirty_confirm(timecard)
    timecard.is_dirty_confirmed = false
    timecard
  end

  def replace_timecard(timecard)

    # TODO: Review this.

    if @updated_timecards.size <= 0
      @updated_timecards.merge!(timecard.id => timecard) unless timecard.nil?
    else
      foundOne = @updated_timecards.find { |_k, v| v.id == timecard.id }
      @updated_timecards.delete('' + timecard.id) unless foundOne.nil?
      @updated_timecards.merge!(timecard.id => timecard) unless timecard.nil?
    end
  end

  def get_dirty_timecard

    # TODO: Can definitely be rewritten.

    dirty_timecard_id = params[:timecard].nil? ? nil : params[:timecard][:dirty_timecard_id]
    if !dirty_timecard_id.nil?
      if @updated_timecards.size <= 0
        @dirty_timecard = @timecards.find { |_k, v| v.id == dirty_timecard_id }[1]
      else
        foundOne = @updated_timecards.find { |_k, v| v.id == dirty_timecard_id }
        if foundOne.nil?
          @dirty_timecard = @timecards.find { |_k, v| v.id == dirty_timecard_id }[1]
        else
          @dirty_timecard = foundOne[1]
        end
      end
      @dirty_timecard.is_dirty = true
      # replace_timecard @dirty_timecard
    else
      @dirty_timecard = nil
    end
  end

  def set_updated_timecard(updated_timecard)

    # TODO: Review.

    unless updated_timecard.nil?
      @updated_timecards = session[:updated_timecards]
      replace_timecard updated_timecard
      # fill_ref_objects_for_updated_timecards
      @total_timecards_updating = 1
      if @dirty_timecard.nil?
        @total_timecards_updating = 0
      else
        session[:updated_timecards].each do |_k, v|
          @total_timecards_updating = 0 if @dirty_timecard.id == v.id
        end
      end
      @total_timecards_updating += session[:updated_timecards].size
      if @total_timecards_updating <= 1
        @localData['are_you_sure_you_want_to_update_this_record'] =  get_localized_text('Are you sure, you want to update this timecard?', true)
      else
        @localData['are_you_sure_you_want_to_update_this_record'] =  get_localized_text('Are you sure, you want to update all ' + @total_timecards_updating.to_s + ' timecards?', true)
      end
    end
  end

  def get_current_page
    params[:page].nil? ? 1 : Integer(params[:page])
  end

  def get_updated_timecards
    @updated_timecards = session[:updated_timecards]
   
    # TODO: Look into.

    if @updated_timecards.nil?
      @updated_timecards = {}
      session[:updated_timecards] = @updated_timecards
    end
  end

  def clear_updated_timecards
    session[:updated_timecards] = nil
  end

  def set_localization_texts
    @localData = {}

    @localData['activity_desc']                                = get_localized_text('Activity Description', true)
    @localData['matter']                                       = get_localized_text('Matter', true)
    @localData['timecardId']                                   = get_localized_text('Timecard', true)
    @localData['client']                                       = get_localized_text('Client', true)
    @localData['timekeeper']                                   = get_localized_text('Timekeeper', true)
    @localData['activityId']                                   = get_localized_text('Activity Code', true)
    @localData['bill_status']                                  = get_localized_text('Bill Status', true)
    @localData['work_hour']                                    = get_localized_text('Hours', true)
    @localData['unit']                                         = get_localized_text('Unit', true)
    @localData['work_date']                                    = get_localized_text('Date', true)
    # @localData['template'] = get_localized_text( 'Template' , true )
    @localData['internal_comment']                             = get_localized_text('Activity Description', true)
    @localData['description']                                  = get_localized_text('Narrative', true)
    @localData['actions']                                      = get_localized_text('Actions', true)
    @localData['timecard_is_posted']                           = get_localized_text('Timecard is posted', true)
    @localData['timecard_is_synced']                           = get_localized_text('Timecard is synced', true)
    @localData['timecard_not_synced']                          = get_localized_text('Timecard is cached', true)
    @localData['records']                                      = get_localized_text('Records ', true)
    @localData['to']                                           = get_localized_text(' to ', true)
    @localData['total_records']                                = get_localized_text(' , total records ', true)
    @localData['posted']                                       = get_localized_text('Posted', true)
    @localData['not_posted']                                   = get_localized_text('Pending', true)
    @localData['synced']                                       = get_localized_text('Synced', true)
    @localData['not_synced']                                   = get_localized_text('Cached', true)
    @localData['status']                                       = get_localized_text('Status', true)
    @localData['edit']                                         = get_localized_text('Edit', true)
    @localData['edit_timecard']                                = get_localized_text('Edit timecard', true)
    @localData['delete']                                       = get_localized_text('Delete', true)
    @localData['delete_timecard']                              = get_localized_text('Delete timecard', true)
    @localData['timecard_not_deletable']                       = get_localized_text('Timecard is not deletable', true)
    @localData['timecard_not_editable']                        = get_localized_text('Timecard is not editable', true)
    @localData['from_date']                                    = get_localized_text('From Date', true)
    @localData['to_date']                                      = get_localized_text('To Date', true)
    @localData['save']                                         = get_localized_text('Save', true)
    @localData['save_new_timecard']                            = get_localized_text('Save new timecard', true)
    @localData['post']                                         = get_localized_text('Post', true)
    @localData['post_new_timecard']                            = get_localized_text('Post new timecard', true)
    @localData['post_existing_timecard']                       = get_localized_text('Post timecard', true)
    @localData['update_changes']                               = get_localized_text('Update', true)
    @localData['update_changed_timecards']                     = get_localized_text('Update changed timecards', true)
    @localData['add_new']                                      = get_localized_text('Add New', true)
    @localData['create_new_timecard']                          = get_localized_text('Create new timecard', true)
    @localData['search']                                       = get_localized_text('Search', true)
    @localData['search_timecards']                             = get_localized_text('Search timecards', true)
    @localData['cancel_changes']                               = get_localized_text('Cancel', true)
    @localData['show_timecards']                               = get_localized_text('Show Timecards', true)
    @localData['new_timecard']                                 = get_localized_text('New Timecard', true)
    @localData['calendar_view']                                = get_localized_text('Calendar View', true)
    @localData['search_text']                                  = get_localized_text('Search Text', true)
    @localData['go']                                           = get_localized_text('Go', true)
    @localData['no_timecard_found_for_these_criteria']         = get_localized_text('No timecard found for these criteria', true)
    @localData['all']                                          = get_localized_text('All', true)
    @localData['weekly_total']                                 = get_localized_text('Weekly Total', true)
    @localData['searched_by_description']                      = get_localized_text('Searched by matter-number, timekeeper-number, client-number, internal comment and description', true)
    @localData['searched_by']                                  = get_localized_text('(Searched by)', true)
    @localData['pending_timecards']                            = get_localized_text('Timecards pending for update:', true)
    @localData['billable']                                     = get_localized_text('Billable', true)
    @localData['non_billable']                                 = get_localized_text('Non-Billable', true)
    # @localData['non_chargeable'] = get_localized_text( 'Non-Chargeable' , true )
    @localData['yes']                                          = get_localized_text('Yes', true)
    @localData['no']                                           = get_localized_text('No', true)
    @localData['new_temp_matter']                              = get_localized_text('New Temp Matter', true)
    @localData['cancel']                                       = get_localized_text('Cancel', true)
    @localData['unable_to_add_temporary_matter']               = get_localized_text('Unable to add temporary matter', true)
    @localData['please_select_a_client']                       = get_localized_text('Please select a client', true)
    @localData['matter_number_is_required']                    = get_localized_text('Matter number is required', true)
    @localData['matter_name_is_required']                      = get_localized_text('Matter name is required', true)
    @localData['matter_number']                                = get_localized_text('Matter Number', true)
    @localData['matter_name']                                  = get_localized_text('Matter Name', true)
    @localData['nick_name']                                    = get_localized_text('Nick Name', true)
    @localData['description_temp_matter']                      = get_localized_text('Description', true)
    @localData['unable_to_get_matter_status']                  = get_localized_text('Unable to get matter status', true)
    @localData['are_you_sure_you_want_to_update_this_record']  = get_localized_text('Are you sure, you want to update this timecard?', true)
    @localData['are_you_sure_you_want_to_delete_the_timecard'] = get_localized_text('Are you sure, you want to delete the timecard?', true)
    @localData['are_you_sure_you_want_to_post_this_record']    = get_localized_text('Are you sure, you want to post this timecard?', true)
    @localData['are_you_sure_you_want_to_cancel_this_record']  = get_localized_text('Are you sure, you want to cancel?', true)
    @localData['billable_non_billable']                        = get_localized_text('Billable/Non-Billable', true)
    @localData['posted_not_posted']                            = get_localized_text('Posted/Pending', true)
    @localData['next']                                         = get_localized_text('Next', true)
    @localData['previous']                                     = get_localized_text('Previous', true)
    @localData['timecard_legend']                              = get_localized_text('Timecard', true)
    @localData['single_error_message']                         = get_localized_text('Please check the field marked with *', true)
    @localData['multiple_error_message']                       = get_localized_text('Please check the #n fields that are marked with *', true)
    @localData['select_hour']                                  = get_localized_text('Select Hour', true)
    @localData['preview']                                      = get_localized_text('Preview', true)
    @localData['bill_status']                                  = get_localized_text('Bill Status', true)
  end

  # this method is overridden
  def generate_single_calendar_cell_data(date_time, within_months_range)
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
    has_timecard     = has_timecard?(date_time_string)
    
    # if( billable == "0:00" && non_billable  == "0:00" && posted  == "0:00" && not_posted  == "0:00" )
    #  has_timecard = false
    # end

    hash1 = {}
    
    hash1['billable']     = billable
    hash1['non_billable'] = non_billable
    hash1['posted']       = posted
    hash1['not_posted']   = not_posted
    hash1['has_timecard'] = has_timecard
    hash1['day']          = date_time.strftime('%d')

    # TODO: Review this. Can be rewritten.

    if @selected_date_string == (date_time_string + date_time_string) # from date, to date
      hash1['class'] = if has_timecard
                         'currentselectionwithtimecard'
                       else
                         'currentselection'
                       end
    elsif today_string == date_time_string
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

    hash1['date']                = date_time_string
    hash1['cell_visible']        = 'display:block;cursor:pointer;'
    hash1['within_months_range'] = within_months_range

    hash1
  end

  # check if the user has selected a date from the calendar view
  def is_calendar_selected
    # set date as the calendar is selected
    is_calendar_selected = false
    calendar_report_object = session[:calendar_report_object]
    
    # TODO: Rewrite.

    if calendar_report_object.nil?
      return false
    else
      calendar_from_date = calendar_report_object['report_date_from']
      calendar_to_date   = calendar_report_object['report_date_to']
      if calendar_from_date == calendar_to_date
        return true
      else
        return false
      end
    end
  end
end
