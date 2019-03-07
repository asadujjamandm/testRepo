require 'timekeeper_utils'
require 'exceptions'
require 'utils'
require 'nsi_services'

class TimekeeperController < BaseController
  before_filter :authenticate

  def index
    #     if (session[SESSION_USER_SUBSCRIPTION_REMAIN_DAYS_ERRORCODE].to_s == '8080')
    #       redirect_to("/subscriptions")
    #       return
    #     end

    # TODO: Refact01

    if !NsiServices.hasPermission(NSI_SERVICE_USER, 'userid' => session[:remember_token][SESSION_LOGIN_INDEX], 'password' => session[:remember_token][SESSION_PASSWORD_INDEX]) || !NsiServices.hasPermission(NSI_SERVICE_ROLE, 'userid' => session[:remember_token][SESSION_LOGIN_INDEX], 'password' => session[:remember_token][SESSION_PASSWORD_INDEX]) # if already signed in then return to home page
      redirect_to('/homes')
      return
    end
    @state = ''
    set_view_properties('Timekeeper')
    clear_search
    search_timekeepers
    set_paginate
    render 'index'
  end

  def set_view_properties(title)
    @menu       = 'master'
    @title      = get_localized_text(title, true)
    @pageheader = get_localized_text(title, true)
    # @current_user_id = get_id
    # @pageheader_image = 'timekeeper.png'
    set_menu_labels
    set_localization_texts
  end

  def search
    @state         = 'search'
    @search_object = TimekeeperUtils.make_search_object(session[:search_object], params[:search_timekeeper])
    render_search
  end

  def render_search
    session[:search_object] = @search_object
    search_timekeepers
    set_paginate
    render 'index'
  end

  def clear_search
    session.delete :search_object
  end

  def set_localization_texts
    @localData = {}

    @localData['timekeeper_no']               = get_localized_text('Timekeeper Number', true)
    @localData['timekeeper_Name']             = get_localized_text('Timekeeper Name', true)
    @localData['display_name']                = get_localized_text('Display Name', true)
    @localData['bill_name']                   = get_localized_text('Bill Name', true)
    @localData['is_active']                   = get_localized_text('Is Active', true)
    @localData['add']                         = get_localized_text('Add', true)
    @localData['edit']                        = get_localized_text('Edit', true)
    @localData['update']                      = get_localized_text('Update', true)
    @localData['disable']                     = get_localized_text('Disable', true)
    @localData['cancel']                      = get_localized_text('Cancel', true)
    @localData['search']                      = get_localized_text('Search', true)
    @localData['search_timekeeper']           = get_localized_text('Search Timekeeper', true)
    @localData['cancel_changes']              = get_localized_text('Cancel Changes', true)
    @localData['edit_timekeeper']             = get_localized_text('Edit Timekeeper', true)
    @localData['update_timekeeper']           = get_localized_text('Update Timekeeper', true)
    @localData['new_timekeeper']              = get_localized_text('New Timekeeper', true)
    @localData['timekeeper_is_not_deletable'] = get_localized_text('Timekeeper disable is not permitted', true)
    @localData['timekeeper_is_not_editable']  = get_localized_text('Timekeeper is not editable', true)
    @localData['single_error_message']        = get_localized_text('Please check the field marked with *', true)
    @localData['multiple_error_message']      = get_localized_text('Please check the #n fields that has been marked with *', true)
    @localData['records']                     = get_localized_text('Records ', true)
    @localData['to']                          = get_localized_text(' to ', true)
    @localData['of']                          = get_localized_text(' , total records ', true)
    @localData['disable_timekeeper']          = get_localized_text('Disable Timekeeper', true)
    @localData['add_new']                     = get_localized_text('Add New', true)
    @localData['create_new']                  = get_localized_text('Create New Timekeeper', true)
    @localData['timekeeper_is_disabled']      = get_localized_text('Timekeeper is disabled', true)
  
  end

  def new
    @state = ''

    # TODO: Refact01

    if !NsiServices.hasPermission(NSI_SERVICE_USER, 'userid' => session[:remember_token][SESSION_LOGIN_INDEX], 'password' => session[:remember_token][SESSION_PASSWORD_INDEX]) || !NsiServices.hasPermission(NSI_SERVICE_ROLE, 'userid' => session[:remember_token][SESSION_LOGIN_INDEX], 'password' => session[:remember_token][SESSION_PASSWORD_INDEX]) # if already signed in then return to home page
      redirect_to('/homes')
      return
    end

    render_new Timekeeper.new
  end

  def create
    new_timekeeper = make_timekeeper(params[:timekeeper])
    message = new_timekeeper.validate(true)
    
    # TODO: This has been written a lot of times now. Consider refactoring.

    if message == ''
      status = post_timekeeper(new_timekeeper)
      if status
        # puts status
        flash[:success] = TIMEKEEPER_INSERT_SUCCESS_MESSAGE
        # render_new new_timekeeper
        redirect_to action: 'new'
      else
        # puts status
        render_new new_timekeeper
      end
    else
      flash.now[:notice] = message
      render_new new_timekeeper
    end
  end

  def update
    set_view_properties('')
    search_timekeepers
    updated_timekeeper = make_timekeeper(params[:timekeeper])
    message = updated_timekeeper.validate(true)
    if message == ''
      if post_timekeeper(updated_timekeeper)
        flash[:success] = TIMEKEEPER_UPDATE_SUCCESS_MESSAGE
        redirect_to action: 'index', page: get_current_page
      else
        render_edit updated_timekeeper
      end
    else
      flash.now[:notice] = message
      render_edit updated_timekeeper
    end
    session[:dirty_t] = nil
  end

  def cancel
    redirect_to action: 'index'
  end

  def edit
    @state            = ''
    search_timekeepers
    @dirty_timekeeper = get_dirty_timekeeper
    session[:dirty_t] = @dirty_timekeeper
    set_paginate
    set_view_properties('Edit Timekeeper')
    render 'index'
    # index
  end

  def render_edit(timekeeper)
    set_view_properties('Edit Timekeeper')
    @dirty_timekeeper = timekeeper
    set_paginate
    render 'index'
  end

  def get_dirty_timekeeper
    dirty_timekeeper_id = params[:timekeeper_id]

    @timekeeper.find { |_k, v| v.id == dirty_timekeeper_id }[1] unless dirty_timekeeper_id.nil?
  end

  def render_new(timekeeper)
    search_timekeepers
    @dirty_timekeeper           = timekeeper
    @dirty_timekeeper.is_active = 'yes' if @dirty_timekeeper.is_active.nil?
    set_paginate
    set_view_properties('New Timekeeper')
    # redirect_to :action => 'index'

    render 'index'
  end

  def make_timekeeper(params_timekeepers)

    # TODO: Review this.

    updated_timekeeper_id = params_timekeepers.nil? ? nil : params_timekeepers[:updated_timekeeper_id]
    
    if !updated_timekeeper_id.nil?
      updated_timekeeper = if !session[:dirty_t].nil?
                             session[:dirty_t]
                           else
                             Timekeeper.new
                           end
      updated_timekeeper.id = updated_timekeeper_id
      TimekeeperUtils.make_timekeeper(params_timekeepers, updated_timekeeper)
    else
      return nil
    end
  end

  def delete
    set_view_properties('')
    delete_timekeeper(params[:timekeeper_id])
    redirect_to action: 'index', page: get_current_page
    # render 'index'
  end

  def delete_timekeeper(timekeeper_id)
    if timekeeper_id.nil? || timekeeper_id.empty?
      flash.now[:error] = TIMEKEEPER_INVALID_MESSAGE
    else
      resp = NsiServices.post(NSI_SERVICE_TIMEKEEPER, { 'userid' => get_login, 'password' => get_pwd }, 'timekeeperid' => timekeeper_id)
      if NsiServices.is_resp_success(resp)
        flash.now[:success] = get_localized_text(TIMEKEEPER_DISABLE_SUCCESS_MESSAGE, true)
      else
        log('Unable to disable timekeeper: ' + NsiServices.resp_message(resp))
        flash.now[:error] = get_localized_text(NsiServices.resp_message(resp), true)
      end
    end
  rescue Exceptions::OperationNotAuthorized => exception
    log_exception_text('Unable to disable timekeeper: ' + OPERATION_NON_AUTHORIZED_MESSAGE)
    flash[:fatalerror] = get_localized_text(OPERATION_NON_AUTHORIZED_MESSAGE, true)
  rescue Exception => e
    log_exception_text('Unable to disable timekeeper: ' + e.message)
    flash[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
  end

  def post_timekeeper(t)
    begin
      postdata = {}
      TimekeeperUtils.make_timekeeper_post_data(postdata, t) unless t.nil?

      resp = NsiServices.post(NSI_SERVICE_TIMEKEEPER, { 'userid' => get_login, 'password' => get_pwd }, postdata)

      if NsiServices.is_resp_success(resp)
            puts '-----------------------------'
    puts 'PART 4'
    puts '-----------------------------'
        return NsiServices.get_resp_return_data(resp)
      else
        log('Cannot update timekeeper: ' + NsiServices.resp_message(resp))
        flash.now[:error] = get_localized_text(NsiServices.resp_message(resp), true)
        return nil
      end
    rescue Exceptions::OperationNotAuthorized => exception
      log_exception_text('Cannot update timekeeper: ' + OPERATION_NON_AUTHORIZED_MESSAGE)
      flash[:fatalerror] = get_localized_text(OPERATION_NON_AUTHORIZED_MESSAGE, true)
      return nil
    rescue Exception => e
      log_exception_text('Cannot update timekeeper: ' + e.message)
      flash[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
      return nil
    end
  end

  def search_timekeepers
    @search_object = session[:search_object]
    postdata = {}
    postdata['timekeepereditlist'] = 'timekeepereditlist'

    # TODO: Review this. Can be rewritten.

    begin
      if !@search_object.nil?
        @timekeeper = NsiServices.get_timekeepers(NsiServices.get(NSI_SERVICE_TIMEKEEPER, { 'userid' => get_login, 'password' => get_pwd, 'timekeepersearchlist' => 'timekeepersearchlist' }, 'TimekeeperNumber' => @search_object.timekeeper_number, 'DisplayName' => @search_object.display_name))
      else
        @timekeeper = NsiServices.get_timekeepers(NsiServices.get(NSI_SERVICE_TIMEKEEPER, 'userid' => get_login, 'password' => get_pwd, 'timekeepereditlist' => 'timekeepereditlist'))
      end
    rescue Exceptions::ServiceNotAuthorized => exception
      log_exception_text('Timekeeper search failed: ' + GENERIC_NON_AUTHORIZED_MESSAGE)
      flash[:fatalerror] = get_localized_text(GENERIC_NON_AUTHORIZED_MESSAGE, true)
      @timekeeper = {}
    rescue Exception => e
      log_exception_text('Timekeeper search failed: ' + e.message)
      flash[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
      @timekeeper = {}
    end
    header = ''
    unless @search_object.nil?

      # TODO: This is written several ones.

      if @search_object.timekeeper_number != ''
        header += 'Search Timekeepers by Number'
      end
      if @search_object.display_name != ''
        if header != ''
          header += ', '
          header += 'Name'
        else
          header += 'Search Timekeepers by Name'
        end
      end
    end
    set_view_properties(header == '' ? 'Timekeeper' : header)
  end

  # TODO: get_timekeeper_page_size is defined manually need to implement the method
  def set_paginate
    @current_page = get_current_page

    # TODO: This is written a few times.

    if @timekeeper.count > 0
      @page_results = WillPaginate::Collection.create(@current_page, 10, @timekeeper.count) do |pager|
        @start = (@current_page - 1) * 10
        # @start = (@current_page)*get_timekeeper_page_size
        pager.replace @timekeeper.to_a[@start, 10]
      end
    end
  end

  def get_current_page
    params[:page].nil? ? 1 : Integer(params[:page])
  end
end
