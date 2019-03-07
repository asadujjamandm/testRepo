require 'activitycode_utils'
require 'exceptions'

class ActivitycodesController < BaseController
  before_filter :authenticate

  def index
    # if (session[SESSION_USER_SUBSCRIPTION_REMAIN_DAYS_ERRORCODE].to_s == '8080')
    #   redirect_to("/subscriptions")
    #   return
    # end

    # TODO: Refact01

    if !NsiServices.hasPermission(NSI_SERVICE_USER, 'userid' => session[:remember_token][SESSION_LOGIN_INDEX], 'password' => session[:remember_token][SESSION_PASSWORD_INDEX]) || !NsiServices.hasPermission(NSI_SERVICE_ROLE, 'userid' => session[:remember_token][SESSION_LOGIN_INDEX], 'password' => session[:remember_token][SESSION_PASSWORD_INDEX]) # if already signed in then return to home page
      redirect_to('/homes')
      return
    end
    @state = ''
    set_view_properties('Activities')
    clear_search
    search_activitycodes
    set_paginate
    render 'index'
  end

  def search
    @state         = 'search'
    @search_object = ActivitycodeUtils.make_search_object(session[:search_object], params[:search_activity])
    render_search
  end

  def render_search
    session[:search_object] = @search_object
    search_activitycodes
    set_paginate
    render 'index'
  end

  def clear_search
    session.delete :search_object
  end

  def set_view_properties(title)
    @menu       = 'master'
    @title      = get_localized_text(title, true)
    @pageheader = get_localized_text(title, true)
    # @current_user_id = get_id
    set_menu_labels
    set_localization_texts
  end

  def set_localization_texts
    @localData = {}

    @localData['activity_code']                 = get_localized_text('Activity Code', true)
    @localData['activity_desc']                 = get_localized_text('Activity Description', true)
    @localData['is_active']                     = get_localized_text('Is Active', true)
    @localData['add']                           = get_localized_text('Add', true)
    @localData['edit']                          = get_localized_text('Edit', true)
    @localData['update']                        = get_localized_text('Update', true)
    @localData['disable']                       = get_localized_text('Disable', true)
    @localData['cancel']                        = get_localized_text('Cancel', true)
    @localData['cancel_changes']                = get_localized_text('Cancel Changes', true)
    @localData['add_new']                       = get_localized_text('Add New', true)
    @localData['create_new']                    = get_localized_text('Create New Activity', true)
    @localData['edit_activitycode']             = get_localized_text('Edit Activity', true)
    @localData['update_activitycode']           = get_localized_text('Update Activity', true)
    @localData['new_activitycode']              = get_localized_text('New Activity', true)
    @localData['activitycode_is_not_deletable'] = get_localized_text('Activity is disabled', true)
    @localData['activitycode_is_not_editable']  = get_localized_text('Activity is not editable', true)
    @localData['single_error_message']          = get_localized_text('Please check the field marked with *', true)
    @localData['multiple_error_message']        = get_localized_text('Please check the #n fields that has been marked with *', true)
    @localData['records']                       = get_localized_text('Records ', true)
    @localData['to']                            = get_localized_text(' to ', true)
    @localData['of']                            = get_localized_text(', total records ', true)
    @localData['disable_activitycode']          = get_localized_text('Disable Activity', true)
    @localData['activitycode_is_disable']       = get_localized_text('Activity disable is not permitted', true)
    @localData['activity_search']               = get_localized_text('Search Activity', true)
    @localData['search']                        = get_localized_text('Search', true)
  end

  def new
    @state = ''

    # TODO: Refact01

    if !NsiServices.hasPermission(NSI_SERVICE_USER, 'userid' => session[:remember_token][SESSION_LOGIN_INDEX], 'password' => session[:remember_token][SESSION_PASSWORD_INDEX]) || !NsiServices.hasPermission(NSI_SERVICE_ROLE, 'userid' => session[:remember_token][SESSION_LOGIN_INDEX], 'password' => session[:remember_token][SESSION_PASSWORD_INDEX]) # if already signed in then return to home page
      redirect_to('/homes')
      return
    end

    render_new Activitycode.new
  end

  def create
    new_activitycode = make_activitycode(params[:activitycode])
    message          = new_activitycode.validate(true)

    if message == ''
      status = post_activitycode(new_activitycode)

      if status
        flash.now[:success] = ACTIVITYCODE_INSERT_SUCCESS_MESSAGE
        redirect_to action: 'new'
      else
        # puts status
        render_new new_activitycode
      end
    else
      flash.now[:notice] = message
      render_new new_activitycode
    end
  end

  def update
    set_view_properties('')
    search_activitycodes

    updated_activitycode = make_activitycode(params[:activitycode])
    message              = updated_activitycode.validate(true)

    if message == ''

      if post_activitycode(updated_activitycode)
        flash.now[:success] = ACTIVITYCODE_UPDATE_SUCCESS_MESSAGE
        # redirect_to :action => 'new'
        redirect_to action: 'index', page: get_current_page
      else
        render_edit updated_activitycode
      end
    else
      flash.now[:notice] = message
      render_edit updated_activitycode
    end
    session[:dirty_a] = nil
  end

  def cancel
    redirect_to action: 'index'
  end

  def edit
    @state = ''
    search_activitycodes
    @dirty_activitycode = get_dirty_activitycode
    session[:dirty_a]   = @dirty_activitycode
    set_paginate
    set_view_properties 'Edit Activity'
    render 'index'
    # index
  end

  def render_edit(activitycode)
    set_view_properties('Edit Activity')
    @dirty_activitycode = activitycode
    set_paginate
    render 'index'
  end

  def get_dirty_activitycode
    dirty_activitycode_id = params[:activitycode_id]
  
    @activitycode.find { |_k, v| v.id == dirty_activitycode_id }[1] unless dirty_activitycode_id.nil?
  end

  def render_new(activitycode)
    search_activitycodes
    @dirty_activitycode           = activitycode
    @dirty_activitycode.is_active = 'yes' if @dirty_activitycode.is_active.nil?
    set_paginate
    set_view_properties('New Activity')
    render 'index'
  end

  def make_activitycode(params_activitycodes)
    updated_activitycode_id = params_activitycodes.nil? ? nil : params_activitycodes[:updated_activitycode_id]
    
    if updated_activitycode_id.nil?
      return nil
    else
      updated_activitycode = session[:dirty_a].nil? ? Activitycode.new : session[:dirty_a]

      updated_activitycode.id = updated_activitycode_id
      ActivitycodeUtils.make_activitycode(params_activitycodes, updated_activitycode)
    end
  end

  def delete
    set_view_properties('')
    delete_activitycode params[:activitycode_id]
    redirect_to action: 'index', page: get_current_page
  end

  def delete_activitycode(activitycode_id)
    if activitycode_id.nil? || activitycode_id.empty?
      flash.now[:error] = ACTIVITYCODE_INVALID_MESSAGE
    else
      resp = NsiServices.post(NSI_SERVICE_ACTIVITYCODE, { 'userid' => get_login, 'password' => get_pwd }, 'activitycodeid' => activitycode_id)
      if NsiServices.is_resp_success(resp)
        flash.now[:success] = get_localized_text(ACTIVITYCODE_DISABLE_SUCCESS_MESSAGE, true)
      else
        log('Unable to disable activitycode: ' + NsiServices.resp_message(resp))
        flash.now[:error] = get_localized_text(NsiServices.resp_message(resp), true)
      end
    end
  rescue Exceptions::OperationNotAuthorized => exception
    log_exception_text('Unable to disable activitycode: ' + OPERATION_NON_AUTHORIZED_MESSAGE)
    flash[:fatalerror] = get_localized_text(OPERATION_NON_AUTHORIZED_MESSAGE, true)
  rescue Exception => e
    log_exception_text('Unable to disable activitycode: ' + e.message)
    flash[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
  end

  def post_activitycode(a)
    postdata = {}
    ActivitycodeUtils.make_activitycode_post_data postdata, a unless a.nil?
    resp = NsiServices.post(NSI_SERVICE_ACTIVITYCODE, { 'userid' => get_login, 'password' => get_pwd }, postdata)
    if NsiServices.is_resp_success(resp)
      return NsiServices.get_resp_return_data(resp)
    else
      log('Cannot update activitycode: ' + NsiServices.resp_message(resp))
      flash.now[:error] = get_localized_text(NsiServices.resp_message(resp), true)
      return nil
    end
  rescue Exceptions::OperationNotAuthorized => exception
    log_exception_text('Cannot update activitycode: ' + OPERATION_NON_AUTHORIZED_MESSAGE)
    flash[:fatalerror] = get_localized_text(OPERATION_NON_AUTHORIZED_MESSAGE, true)
    return nil
  rescue Exception => e
    log_exception_text('Cannot update timekeeper: ' + e.message)
    flash[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
    return nil
  end

  def search_activitycodes
    postdata = {}
    postdata['activitycodeeditlist'] = 'activitycodeeditlist'

    @search_object = session[:search_object]

    begin

      # TODO: Rewritten to ternary but can still be reduced, probably.

      @activitycode = @search_object.nil? ?
                NsiServices.get_activitycodes(NsiServices.get(NSI_SERVICE_ACTIVITYCODE, { 'userid' => get_login, 'password' => get_pwd, 'activitycodesearchlist' => 'activitycodesearchlist' }, 'activitycode' => @search_object.activity_code, 'activitydesc' => @search_object.activity_desc)) :
                NsiServices.get_activitycodes(NsiServices.get(NSI_SERVICE_ACTIVITYCODE, 'userid' => get_login, 'password' => get_pwd, 'activitycodeeditlist' => 'activitycodeeditlist'))
    rescue Exceptions::ServiceNotAuthorized => exception
      log_exception_text('Activitycode search failed: ' + GENERIC_NON_AUTHORIZED_MESSAGE)
      flash[:fatalerror] = get_localized_text(GENERIC_NON_AUTHORIZED_MESSAGE, true)
      @activitycode = {}
    rescue Exception => e
      log_exception_text('Activitycode search failed: ' + e.message)
      flash[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
      @activitycode = {}
    end

    header = ''

    # TODO: Rewrite this

    unless @search_object.nil?
      header += 'Search Activity by Number' unless @search_object.activity_code == ''
      
      header += header == '' ? 'Search Activity by Name' : ', Name' unless @search_object.activity_desc == ''
    end
    set_view_properties(header == '' ? 'Activity' : header)
  end

  # TODO: get_activitycode_page_size is defined manually need to implement the method
  
  def set_paginate
    @current_page = get_current_page
    if @activitycode.count > 0
      @page_results = WillPaginate::Collection.create(@current_page, 10, @activitycode.count) do |pager|
        @start = (@current_page - 1) * 10
        # @start = (@current_page)*get_timekeeper_page_size
        pager.replace @activitycode.to_a[@start, 10]
      end
    end
  end

  def get_current_page
    params[:page].nil? ? 1 : Integer(params[:page])
  end
end
