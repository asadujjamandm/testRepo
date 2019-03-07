require 'exceptions'

class RegisteredUsersController < BaseController
  before_filter :authenticate

  def index

    # TODO: Refact01

    if session[SESSION_USER_SUBSCRIPTION_REMAIN_DAYS_ERRORCODE].to_s == '8080'
      redirect_to('/subscriptions')
      return
    end

    unless NsiServices.hasPermission(NSI_SERVICE_USER_REG, 'userid' => get_login, 'password' => get_pwd) # if already signed in then return to home page
      redirect_to('/homes')
      return
    end

    set_view_properties
    get_roles
    search_registeredusers
    set_paginate
    render 'index'
  end

  def create_farm
    @farm_setting  = FarmSetting.new(params[:farm_setting])
    regid          = params[:regid]
    farm_name_list = params[:farm_name_list]

    status, msg = post_data(@farm_setting, regid, farm_name_list)
    
    # TODO: What is status supposed to return? Look into this?

    if status == true
      # UserMailer.welcome_email(new_user).deliver
      flash[:success] = msg
      redirect_to action: 'index'
    else
      redirect_to action: 'index'
    end
  end

  def cancel
  end

  def delete
    set_view_properties
    delete_user params[:reguser_id]
    redirect_to action: 'index', page: get_current_page
  end

  def confirm
    confirm_user params[:reguser_id]
    redirect_to action: 'index', page: get_current_page
  end

  def confirm_user(reguser_id)

    # TODO: Look into.

    if reguser_id.nil? || reguser_id.empty?
      flash.now[:error] = REGSITEREDUSER_INVALID_MESSAGE
    else
      resp = NsiServices.post(NSI_SERVICE_USER_REG, { 'userid' => get_login, 'password' => get_pwd, 'userconfirm' => 'userconfirm' }, 'regid' => reguser_id)
      if NsiServices.is_resp_success(resp)
        flash[:success] = get_localized_text(NEWUSER_CREATE_SUCCESS_MESSAGE, true)
      else
        log('Unable to create new user: ' + NsiServices.resp_message(resp))
        flash[:error] = get_localized_text(NsiServices.resp_message(resp), true)
      end
    end
  rescue Exceptions::OperationNotAuthorized => exception
    log_exception_text('Unable to create new user: ' + OPERATION_NON_AUTHORIZED_MESSAGE)
    flash[:fatalerror] = get_localized_text(OPERATION_NON_AUTHORIZED_MESSAGE, true)
  rescue Exception => e
    log_exception_text('Unable to create new user: ' + e.message)
    flash[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
  end

  def search_registeredusers
    postdata = {}
    postdata['registeredusers'] = 'registeredusers'

    begin
      @registeredusers = NsiServices.get_registeredusers(NsiServices.get(NSI_SERVICE_USER_REG, 'userid' => get_login, 'password' => get_pwd, 'registeredusers' => 'registeredusers'))
    rescue Exceptions::ServiceNotAuthorized => exception
      log_exception_text('Registered Users search failed: ' + GENERIC_NON_AUTHORIZED_MESSAGE)
      flash[:fatalerror] = get_localized_text(GENERIC_NON_AUTHORIZED_MESSAGE, true)
      @registeredusers = {}
    rescue Exception => e
      log_exception_text('Registered user search failed: ' + e.message)
      flash[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
      @registeredusers = {}
    end
  end

  def autocomplete_list
    # search_criteria = params["term"]
    extra_id = params['extra_id']
    type     = params['type']
    # userid = params["userid"]
    # dirty_id = @dirty_user.id
    uid      = get_login
    pwd      = get_pwd

    begin
      # @records = get_autocomplete uid, pwd, type, search_criteria, extra_id
      @records = get_autocomplete(uid, pwd, type, extra_id)
    rescue Exception => e
      log_exception_text('Autocomplete dropdown list farm name loading failed: ' + e.message)
      throw 'An error occured11'
    end
    render(layout: false) # layout false because its ajax
  end

  def get_autocomplete(uid, pwd, type, extra_id)
    postdata = {}
    
    postdata['type']    = type
    postdata['extraId'] = extra_id

    begin
      return NsiServices.get_autocomplete(NsiService.get(NSI_SERVICE_AUTOCOMPLETE, { 'userid' => uid, 'password' => pwd }, postdata))
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

  def get_roles
    @roles = NsiServices.get_roles(NsiServices.get(NSI_SERVICE_ROLE, 'userid' => get_login, 'password' => get_pwd))
  rescue Exceptions::ServiceNotAuthorized => exception
    log_exception_text('Cannot get role list: ' + GENERIC_NON_AUTHORIZED_MESSAGE)
    flash.now[:fatalerror] = get_localized_text(GENERIC_NON_AUTHORIZED_MESSAGE, true)
    @roles = {}
  rescue Exception => e
    log_exception_text('Cannot get role list: ' + e.message)
    flash.now[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
    @roles = {}
  end

  private

  def post_data(inputData, inputId, farmName)
    postdata = {}
    
    make_post_data(postdata, inputData, inputId, farmName)
    
    resp = NsiServices.post(NSI_SERVICE_FARM_SETTING, { 'userid' => get_login, 'password' => get_pwd, 'farmentry' => 'farmentry' }, postdata)
    
    if NsiServices.is_resp_success(resp)
      return true, NsiServices.get_resp_return_data(resp)
    else
      log('Farm not saved: ' + NsiServices.resp_message(resp))
      flash.now[:error] = get_localized_text(FARM_SETTING_ADD_ERROR, true)
      return false
    end
  rescue Exceptions::OperationNotAuthorized => exception
    log_exception_text('Firm not saved: ' + OPERATION_NON_AUTHORIZED_MESSAGE)
    flash[:fatalerror] = get_localized_text(OPERATION_NON_AUTHORIZED_MESSAGE, true)
  rescue Exception => e
    log_exception_text('Firm not saved: ' + e.message)
    flash[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
  end

  def make_post_data(postdata, data, id, farmName)

    # TODO: Rewrite this

    postdata['farm_name'] = if farmName == ''
                              data.farm_name
                            else
                              farmName
                            end
    postdata['xml_export_path0']           = data.xml_export_path
    postdata['daysoftimecardinmobicache0'] = data.setting_timcard_persistent_days
    postdata['sync_enabled']               = data.sync_enabled
    postdata.merge!('regid' => id)
  end

  def set_view_properties
    @menu             = 'admin'
    @title            = get_localized_text('Registered User', true)
    @pageheader       = @title
    @pageheader_image = 'reg_user.png'
    set_menu_labels
    set_localization_texts
  end

  def delete_user(reguser_id)

    # TODO: Rewrite nil or empty

    if reguser_id.nil? || reguser_id.empty?
      flash[:error] = USER_INVALID_MESSAGE
    else
      resp = NsiServices.delete(NSI_SERVICE_USER_REG, { 'userid' => get_login, 'password' => get_pwd }, 'regid' => reguser_id)
      if NsiServices.is_resp_success(resp)
        flash[:success] = get_localized_text(USER_DELETE_SUCCESS_MESSAGE, true)
      else
        log('Unable to delete user: ' + NsiServices.resp_message(resp))
        flash[:error] = get_localized_text(NsiServices.resp_message(resp), true)
      end
    end
  rescue Exceptions::OperationNotAuthorized => exception
    log_exception_text('Unable to delete user: ' + OPERATION_NON_AUTHORIZED_MESSAGE)
    flash[:fatalerror] = get_localized_text(OPERATION_NON_AUTHORIZED_MESSAGE, true)
  rescue Exception => e
    log_exception_text('Unable to delete user: ' + e.message)
    flash[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
  end

  def set_localization_texts
    @localData = {}
    
    @localData['add_new_farm']             = get_localized_text('Add new Firm', true)
    @localData['confirm_user']             = get_localized_text('Confirm this user', true)
    @localData['farm_name']                = get_localized_text('Firm Name', true)
    @localData['xml_export_path']          = get_localized_text('Xml_Export_path', true)
    @localData['sync_enabled']             = get_localized_text('Sync Enabled', true)
    @localData['add']                      = get_localized_text('Add', true)
    @localData['cancel']                   = get_localized_text('cancel', true)
    @localData['cancel_changes']           = get_localized_text('Cancel Changes', true)
    @localData['records']                  = get_localized_text('Records ', true)
    @localData['to']                       = get_localized_text(' to ', true)
    @localData['of']                       = get_localized_text(' of ', true)
    @localData['single_error_message']     = get_localized_text('Please check the field marked with *', true)
    @localData['multiple_error_message']   = get_localized_text('Please check the #n fields that has been marked with *', true)
    @localData['timecard_persistent_days'] = get_localized_text('Cache timecards for (days)', true)
    @localData['delete']                   = get_localized_text('Delete', true)
    @localData['delete_user']              = get_localized_text('Delete user', true)
  end
end

# TODO: get_timekeeper_page_size is defined manually need to implement the method
def set_paginate
  @current_page = get_current_page

  # TODO: Look into.

  if @registeredusers.count > 0
    @page_results = WillPaginate::Collection.create(@current_page, 10, @registeredusers.count) do |pager|
      @start = (@current_page - 1) * 10
      pager.replace @registeredusers.to_a[@start, 10]
    end
  end
end

def get_current_page
  params[:page].nil? ? 1 : Integer(params[:page])
end
