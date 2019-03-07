require 'nsi_services'
require 'exceptions'
require 'Matter_Utils'

class MatterController < BaseController
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
    set_view_properties('Matters')
    # @dirty_matter= Matter.new
    set_localization_texts
    clear_search
    search_matters
    set_paginate
    render 'index'
  end

  #-----------------create functions------------------
  def create
    new_matter = make_matter params[:matter]
    # message = new_matter.validate true     # Need to be written later
   
    # TODO: Look into this

    message = '' # need to be deletedss later
    if message == ''
      
      status, matter_id = post_matter(new_matter, '0') # if edit the than send matter number
      
      if status && !matter_id.nil?
        flash.now[:success] = MATTER_INSERT_SUCCESS_MESSAGE
        redirect_to action: 'new'
        # render 'index'
      else
        render_new new_matter
      end
    else
      flash.now[:notice] = message
      render_new new_matter
    end
  end

  def new
    @state = ''

    # TODO: Refact01
    
    if !NsiServices.hasPermission(NSI_SERVICE_USER, 'userid' => session[:remember_token][SESSION_LOGIN_INDEX], 'password' => session[:remember_token][SESSION_PASSWORD_INDEX]) || !NsiServices.hasPermission(NSI_SERVICE_ROLE, 'userid' => session[:remember_token][SESSION_LOGIN_INDEX], 'password' => session[:remember_token][SESSION_PASSWORD_INDEX]) # if already signed in then return to home page
      redirect_to('/homes')
      return
    end
    
    render_new Matter.new
  end

  def render_new(matter)
    @dirty_matter           = matter
    @dirty_matter.is_active = 'yes' if @dirty_matter.is_active.nil?
    @dirty_matter.mt_udf9   = 'yes' if @dirty_matter.mt_udf9.nil?
    @dirty_matter.id        = '0'
    # get matter Number
    search_matters
    set_paginate
    set_view_properties('New matter')
    render 'index'
  end

  def search
    @state         = 'search'
    @search_object = Matter_Utils.make_search_object(session[:search_object], params[:search_matter])
    render_search
  end

  def cancel
    redirect_to action: 'index'
  end

  def render_search
    session[:search_object] = @search_object
    search_matters
    set_paginate
    render 'index'
  end

  def clear_search
    session.delete :search_object
  end

  def edit
    @state            = ''
    search_matters
    @dirty_matter     = get_dirty_matter
    session[:dirty_m] = @dirty_matter
    # set_paginate
    set_view_properties('Edit matter')
    set_paginate
    render 'index'
  end

  def update
    set_view_properties('')
    # search_matters
    updated_matter = make_matter params[:matter]
    # message = updated_matter.validate false

    # TODO: Look into this

    message = ''
    if message == ''
      if post_matter(updated_matter, updated_matter.id)
        flash.now[:success] = MATTER_UPDATE_SUCCESS_MESSAGE
        # redirect_to :action => 'search', :page => get_current_page
        redirect_to action: 'index'
      else
        # render_edit updated_matter
        redirect_to action: 'new'
      end
    else
      flash.now[:notice] = message
      # render_edit updated_matter
      redirect_to action: 'index'
    end
    session[:dirty_m] = Matter.new
  end

  def get_dirty_matter
    dirty_matter_id = params[:matter_id]
    
    @matters.find { |_k, v| v.id == dirty_matter_id }[1] unless dirty_matter_id.nil?
  end

  #-------------------------------
  def delete
    set_view_properties('')
    delete_matter(params[:matter_id])
    redirect_to action: 'index', page: get_current_page
  end

  def delete_matter(matter_id)

    # TODO: Make a nil or empty method.

    if matter_id.nil? || matter_id.empty?
      flash.now[:error] = MATTER_UPDATE_SUCCESS_MESSAGE
    else
      resp = NsiServices.delete(NSI_SERVICE_MATTER, { 'userid' => get_login, 'password' => get_pwd }, 'matterID' => matter_id)
      
      if NsiServices.is_resp_success(resp)
        flash.now[:success] = get_localized_text(MATTER_DELETE_SUCCESS_MESSAGE, true)
      else
        log('Unable to delete matter: ' + NsiServices.resp_message(resp))
        flash.now[:error] = get_localized_text(NsiServices.resp_message(resp), true)
      end
    end
  rescue Exceptions::OperationNotAuthorized => exception
    log_exception_text('Unable to delete matter: ' + OPERATION_NON_AUTHORIZED_MESSAGE)
    flash[:fatalerror] = get_localized_text(OPERATION_NON_AUTHORIZED_MESSAGE, true)
  rescue Exception => e
    log_exception_text('Unable to delete matter: ' + e.message)
    flash[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
  end

  def make_matter(params_matter)
    updated_matter_id = params_matter.nil? ? nil : params_matter[updated_matter_id]
    
    # TODO: Rewrite

    if !updated_matter_id.nil?
      updated_matter = if !session[:dirty_m].nil?
                         session[:dirty_m]
                       else
                         Matter.new
                       end
      updated_matter.id = updated_matter_id
      Matter_Utils.make_matter(params_matter, updated_matter)
    else
      return nil
    end
  end

  def post_matter(c, id)
    postdata = {}
    Matter_Utils.make_matter_post_data postdata, c, id unless c.nil?
    resp = NsiServices.post(NSI_SERVICE_MATTER, { 'userid' => get_login, 'password' => get_pwd, 'deviceid' => 'webapp' }, postdata)
    if NsiServices.is_resp_success(resp)
      return true, NsiServices.get_resp_return_data(resp)
    else
      log('Cannot update matter: ' + NsiServices.resp_message(resp))
      flash.now[:error] = get_localized_text(NsiServices.resp_message(resp), true)
      return false, nil
    end
  rescue Exceptions::OperationNotAuthorized => exception
    log_exception_text('Cannot update matter: ' + OPERATION_NON_AUTHORIZED_MESSAGE)
    flash[:fatalerror] = get_localized_text(OPERATION_NON_AUTHORIZED_MESSAGE, true)
    return false, nil
  rescue Exception => e
    log_exception_text('Cannot update matter: ' + e.message)
    flash[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
    return false, nil
  end

  def set_localization_texts
    @localData = {}
    @localData['matter_is_not_editable']  = get_localized_text('Mattter is not editable', true)
    @localData['matter_is_not_deletable'] = get_localized_text('Mattter disable is not permitted', true)
    @localData['save']                    = get_localized_text('Save', true)
    @localData['new_matter']              = get_localized_text('New matter', true)
    @localData['edit_matter']             = get_localized_text('Edit matter', true)
    @localData['delete_matter']           = get_localized_text('Disable matter', true)
    @localData['post']                    = get_localized_text('Post', true)
    @localData['cancel_changes']          = get_localized_text('Cancel', true)
    @localData['update_changes']          = get_localized_text('Update', true)
    @localData['save_new_timecard']       = get_localized_text('Saved', true)
    @localData['post_new_timecard']       = get_localized_text('posted', true)
    @localData['save_new_timecard']       = get_localized_text('New', true)
    @localData['records']                 = get_localized_text('Records ', true)
    @localData['to']                      = get_localized_text(' to ', true)
    @localData['of']                      = get_localized_text(' , total records ', true)
    @localData['delete']                  = get_localized_text('delete', true)
    @localData['add_new']                 = get_localized_text('Add New', true)
    @localData['create_new']              = get_localized_text('Create New Matter', true)
    @localData['matter_no']               = get_localized_text('Matter No', true)
    @localData['matter_name']             = get_localized_text('Matter Name', true)
    @localData['matter_search']           = get_localized_text('Matter Search', true)
    @localData['search']                  = get_localized_text('Search', true)
  end

  def search_matters
    postdata = {}
    postdata['mattereditlist'] = 'mattereditlist'

    @search_object = session[:search_object]
    begin

      # TODO: Rewrite this.

      if !@search_object.nil?
        @matters = NsiServices.get_matters(NsiServices.get(NSI_SERVICE_MATTER, { 'userid' => get_login, 'password' => get_pwd, 'mattersearchlist' => 'mattersearchlist' }, 'matterNumber' => @search_object.matter_number, 'matterName' => @search_object.matter_name))
      else
        @matters = NsiServices.get_matters(NsiServices.get(NSI_SERVICE_MATTER, { 'userid' => get_login, 'password' => get_pwd, 'mattereditlist' => 'mattereditlist' }, postdata))
      end
    rescue Exceptions::ServiceNotAuthorized => exception
      log_exception_text('Timekeeper search failed: ' + GENERIC_NON_AUTHORIZED_MESSAGE)
      flash[:fatalerror] = get_localized_text(GENERIC_NON_AUTHORIZED_MESSAGE, true)
      @matters = {}
    rescue Exception => e
      log_exception_text('Timekeeper search failed: ' + e.message)
      flash[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
      @matters = {}
    end

    header = ''

    # TODO: Rewrite this.

    unless @search_object.nil?
      header += 'Search Matter by Number' if @search_object.matter_number != ''
      if @search_object.matter_name != ''
        if header != ''
          header += ', '
          header += 'Name'
        else
          header += 'Search Matter by Name'
        end
      end
    end
    set_view_properties(header == '' ? 'Matter' : header
  end

  def autocomplete_list
    puts 'autocomplete'

    search_criteria = params['term']
    extra_id        = params['extra_id']
    type            = params['type']
    uid             = get_login
    pwd             = get_pwd

    begin
      @records = get_autocomplete uid, pwd, type, search_criteria, extra_id
    rescue Exception => e
      log_exception_text('Autocomplete dropdown list for matter, client or timekeeper loading failed: ' + e.message)
      throw 'An error occured'
    end

    render(layout: false) # layout false because its ajax
  end

  private

  def set_view_properties(title)
    @menu            = 'master'
    @title           = get_localized_text(title, true)
    @pageheader      = get_localized_text(title, true)
    # @pageheader_image = 'user.png'
    @current_user_id = get_id
    set_menu_labels
    set_localization_texts
  end

  def set_paginate
    @current_page = get_current_page

    # TODO: Look into this.

    if @matters.count > 0
      @page_results = WillPaginate::Collection.create(@current_page, 10, @matters.count) do |pager|
        @start = (@current_page - 1) * 10
        # @start = (@current_page)*get_timekeeper_page_size
        pager.replace @matters.to_a[@start, 10]
      end
    end
  end

  def get_current_page
    params[:page].nil? ? 1 : Integer(params[:page])
  end

  def get_autocomplete(uid, pwd, type, key, extra_id)
    postdata = {}
    
    postdata['type']    = type
    postdata['key']     = key
    postdata['extraId'] = extra_id

    begin
      return NsiServices.get_autocomplete(NsiServices.get(NSI_SERVICE_AUTOCOMPLETE, { 'userid' => uid, 'password' => pwd }, postdata))
    rescue Exceptions::ServiceNotAuthorized => exception
      log_exception_text('Autocomplete load error: ' + GENERIC_NON_AUTHORIZED_MESSAGE)
      flash.now[:fatalerror] = get_localized_text(GENERIC_NON_AUTHORIZED_MESSAGE, true)
      return {}
    rescue Exception => e
      log_exception_text('Autocomplete load error: ' + e.message)
      flash.now[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
      return {}
    end
  end
end
