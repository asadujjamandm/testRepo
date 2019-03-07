require 'nsi_services'
require 'exceptions'
require 'Client_Utils'

class ClientController < BaseController
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
    set_view_properties('Clients')
    clear_search
    search_clients
    set_paginate
    render 'index'
  end

  def create
    new_client = make_client params[:client]
    # message = new_client.validate true     # Need to be written later
    
    message = '' # need to be deletedss later
    
    # TODO: Rewrite this.

    if message == ''
      status, client_id = post_client new_client, '0' # if edit the than send client number
      
      if status && !client_id.nil?
        flash[:success] = CLIENT_INSERT_SUCCESS_MESSAGE
        redirect_to action: 'new'
        # render 'index'
      else
        render_new new_client
      end
    else
      flash.now[:notice] = message
      render_new new_client
    end
  end

  def edit
    @state = ''
    search_clients
    @dirty_client     = get_dirty_client
    session[:dirty_c] = @dirty_client
    set_view_properties('Edit client')
    set_paginate
    render 'index'
  end

  def search
    @state         = 'search'
    @search_object = Client_Utils.make_search_object(session[:search_object], params[:search_client])
    render_search
  end

  def render_search
    session[:search_object] = @search_object
    search_clients
    set_paginate
    render 'index'
  end

  def cancel
    redirect_to action: 'index'
  end

  def clear_search
    session.delete :search_object
  end

  def get_dirty_client
    dirty_client_id = params[:client_id]
    @dirty_id       = session[:dirty_c]
    dirty_client_id = @dirty_id.id if dirty_client_id.nil?

    @clients.find { |_k, v| v.id == dirty_client_id }[1] unless dirty_client_id.nil?
  end

  def update
    set_view_properties('')
    search_clients
    updated_client = make_client params[:client]
    # message = updated_client.validate false
    message = ''
    
    if message == ''
      if post_client(updated_client, updated_client.id)
        flash.now[:success] = CLIENT_UPDATE_SUCCESS_MESSAGE
        # redirect_to :action => 'search', :page => get_current_page
        redirect_to action: 'index'
      else
        render_edit updated_client
      end
    else
      flash.now[:notice] = message
      render_edit updated_client
    end

    session[:dirty_c] = Client.new
  end

  def delete
    set_view_properties('')
    delete_client(params[:client_id])
    redirect_to action: 'index', page: get_current_page
  end

  def delete_client(client_id)

    # TODO: Look into rewriting this

    if client_id.nil? || client_id.empty?
      flash.now[:error] = CLIENT_UPDATE_SUCCESS_MESSAGE
    else
      resp = NsiServices.delete(NSI_SERVICE_CLIENT, { 'userid' => get_login, 'password' => get_pwd }, 'id' => client_id)
      if NsiServices.is_resp_success(resp)
        flash.now[:success] = get_localized_text(CLIENT_DELETE_SUCCESS_MESSAGE, true)
      else
        log('Unable to delete client: ' + NsiServices.resp_message(resp))
        flash.now[:error] = get_localized_text(NsiServices.resp_message(resp), true)
      end
    end
  rescue Exceptions::OperationNotAuthorized => exception
    log_exception_text('Unable to delete client: ' + OPERATION_NON_AUTHORIZED_MESSAGE)
    flash[:fatalerror] = get_localized_text(OPERATION_NON_AUTHORIZED_MESSAGE, true)
  rescue Exception => e
    log_exception_text('Unable to delete client: ' + e.message)
    flash[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
  end

  def make_client(params_client)
    updated_client_id = params_client.nil? ? nil : params_client[:updated_client_id]
    
    # TODO: Rewrite.

    if !updated_client_id.nil?
      updated_client = if !session[:dirty_c].nil?
                         session[:dirty_c]
                       else
                         Client.new
                       end
      updated_client.id = updated_client_id
      Client_Utils.make_client(params_client, updated_client)
    else
      return nil
    end
  end

  def new
    @state = ''

    if !NsiServices.hasPermission(NSI_SERVICE_USER, 'userid' => session[:remember_token][SESSION_LOGIN_INDEX], 'password' => session[:remember_token][SESSION_PASSWORD_INDEX]) || !NsiServices.hasPermission(NSI_SERVICE_ROLE, 'userid' => session[:remember_token][SESSION_LOGIN_INDEX], 'password' => session[:remember_token][SESSION_PASSWORD_INDEX]) # if already signed in then return to home page
      redirect_to('/homes')
      return
    end

    render_new Client.new
  end

  def render_new(client)
    @dirty_client           = client
    @dirty_client.is_active = 'yes' if @dirty_client.is_active.nil?
    @dirty_client.cl_udf9   = 'yes' if @dirty_client.cl_udf9.nil?
    @dirty_client.id        = '0'

    # get client Number
    
    search_clients
    set_paginate
    set_view_properties('New client')
    render 'index'
  end

  def post_client(c, id)
    postdata = {}
    
    Client_Utils.make_client_post_data(postdata, c, id) unless c.nil?

    resp = NsiServices.post(NSI_SERVICE_CLIENT, { 'userid' => get_login, 'password' => get_pwd }, postdata)
    
    if NsiServices.is_resp_success(resp)
      return true, NsiServices.get_resp_return_data(resp)
    else
      log('Cannot update client: ' + NsiServices.resp_message(resp))
      flash.now[:error] = get_localized_text(NsiServices.resp_message(resp), true)
      return false, nil
    end
  rescue Exceptions::OperationNotAuthorized => exception
    log_exception_text('Cannot update client: ' + OPERATION_NON_AUTHORIZED_MESSAGE)
    flash[:fatalerror] = get_localized_text(OPERATION_NON_AUTHORIZED_MESSAGE, true)
    return false, nil
  rescue Exception => e
    log_exception_text('Cannot update client: ' + e.message)
    flash[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
    return false, nil
  end

  def set_localization_texts
    @localData = {}
    @localData['role_view_is_not_enabled']
    @localData['edit_client']              = get_localized_text('Edit', true)
    @localData['client_is_not_deletable']  = get_localized_text('Client disable is not permitted', true)
    @localData['delete_client']            = get_localized_text('Disable Client', true)
    @localData['save']                     = get_localized_text('Save', true)
    @localData['new_client']               = get_localized_text('New client', true)
    @localData['post']                     = get_localized_text('Post', true)
    @localData['cancel_changes']           = get_localized_text('Cancel', true)
    @localData['update_changes']           = get_localized_text('Update', true)
    @localData['save_new_timecard']        = get_localized_text('Saved', true)
    @localData['post_new_timecard']        = get_localized_text('posted', true)
    @localData['save_new_timecard']        = get_localized_text('New', true)
    @localData['records']                  = get_localized_text('Records ', true)
    @localData['to']                       = get_localized_text(' to ', true)
    @localData['of']                       = get_localized_text(' , total records ', true)
    @localData['delete']                   = get_localized_text('delete', true)
    @localData['add_new']                  = get_localized_text('Add New', true)
    @localData['create_new']               = get_localized_text('Create New Client', true)
    @localData['client_no']                = get_localized_text('Client Number', true)
    @localData['client_name']              = get_localized_text('Client Name', true)
    @localData['search_client']            = get_localized_text('Search Client', true)
    @localData['search']                   = get_localized_text('Search', true)
  end

  def search_clients
    postdata = {}
    postdata['clienteditlist'] = 'clienteditlist'

    @search_object = session[:search_object]
    begin

      # TODO: Rewrite this.

      if !@search_object.nil?
        @clients = NsiServices.get_clients(NsiServices.get(NSI_SERVICE_CLIENT, { 'userid' => get_login, 'password' => get_pwd, 'clientsearchlist' => 'clientsearchlist' }, 'clientnumber' => @search_object.client_number, 'clientname' => @search_object.client_name))
      else
        @clients = NsiServices.get_clients(NsiServices.get(NSI_SERVICE_CLIENT, { 'userid' => get_login, 'password' => get_pwd, 'clienteditlist' => 'clienteditlist' }, postdata))
      end
    rescue Exceptions::ServiceNotAuthorized => exception
      log_exception_text('Timekeeper search failed: ' + GENERIC_NON_AUTHORIZED_MESSAGE)
      flash[:fatalerror] = get_localized_text(GENERIC_NON_AUTHORIZED_MESSAGE, true)
      @clients = {}
    rescue Exception => e
      log_exception_text('Timekeeper search failed: ' + e.message)
      flash[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
      @clients = {}
    end

    header = ''

    unless @search_object.nil?
      header += 'Search Clients by Number' if @search_object.client_number != ''
      
      # TODO: Rewrite this.

      if @search_object.client_name != ''
        if header != ''
          header += ', '
          header += 'Name'
        else
          header += 'Search Clients by Name'
        end
      end
    end

    set_view_properties(header == '' ? 'Client' : header)
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

    # TODO: Look into rewriting this.

    if @clients.count > 0
      @page_results = WillPaginate::Collection.create(@current_page, 10, @clients.count) do |pager|
        @start = (@current_page - 1) * 10
        # @start = (@current_page)*get_timekeeper_page_size
        pager.replace @clients.to_a[@start, 10]
      end
    end
  end

  def get_current_page
    params[:page].nil? ? 1 : Integer(params[:page])
  end
end
