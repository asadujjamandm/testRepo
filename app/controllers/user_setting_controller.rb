require 'exceptions'

class UserSettingController < BaseController
  before_filter :authenticate

  def index

    # TODO: Refact01

    if session[SESSION_USER_SUBSCRIPTION_REMAIN_DAYS_ERRORCODE].to_s == '8080'
      redirect_to('/subscriptions')
      return
    end
    set_view_properties

    get_user_settings

    set_paginate
  end

  def update

    # TODO: Review.

    if params['setting_value'].nil?
      redirect_to action: 'index'
      return
    end

    post_data(params['setting_value'])
    set_user_settings
    set_view_properties
    get_user_settings
    set_paginate
    render 'index'
  end

  private

  def set_view_properties
    @menu             = 'preference'
    @title            = get_localized_text('Change User Settings', true)
    @pageheader       = @title
    @pageheader_image = 'settings.png'
    set_menu_labels
    set_localization_texts
  end

  def get_user_settings
    @user_settings = NsiServices.get_user_settings(NsiServices.get(NSI_SERVICE_USER_SETTING, 'userid' => get_login, 'password' => get_pwd))

    flash.now[:error] = get_localized_text(GENERIC_NON_AUTHORIZED_MESSAGE, true) if @user_settings.nil? || @user_settings.empty?


    # set display labels for keys
    @labels = {}
    
    @labels['ROLE_PAGE_SIZE']            = get_localized_text('Role page size', true)
    @labels['TIMECARD_PAGE_SIZE']        = get_localized_text('Time card page size', true)
    @labels['TIMECARD_REPORT_PAGE_SIZE'] = get_localized_text('Timecard report page size', true)
    @labels['USER_PAGE_SIZE']            = get_localized_text('User page size', true)

    @erp_user_id = NsiServices.get_erp_user(NsiServices.get(NSI_SERVICE_ERP_USER, 'userid' => get_login, 'password' => get_pwd))

  rescue Exceptions::ServiceNotAuthorized => exception
    log_exception_text('Cannot load user settings: ' + GENERIC_NON_AUTHORIZED_MESSAGE)
    flash.now[:fatalerror] = get_localized_text(GENERIC_NON_AUTHORIZED_MESSAGE, true)
    @user_settings = {}
  rescue Exception => e
    log_exception_text('Cannot load user settings: ' + e.message)
    flash.now[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
    @user_settings = {}
  end

  def set_paginate
    @current_page = get_current_page

    if @user_settings.count > 0
      @page_results = WillPaginate::Collection.create(@current_page, USER_SETTING_PAGE_SIZE, @user_settings.count) do |pager|
        @start = (@current_page - 1) * USER_SETTING_PAGE_SIZE
        pager.replace @user_settings.to_a[@start, USER_SETTING_PAGE_SIZE]
      end
    end
  end

  def get_current_page
    params[:page].nil? ? 1 : Integer(params[:page])
  end

  def post_data(inputData)
    postdata = {}

    # TODO: Review this method.

    make_post_data(postdata, inputData)
    resp = NsiServices.post(NSI_SERVICE_USER_SETTING, { 'userid' => get_login, 'password' => get_pwd }, postdata)
    if NsiServices.is_resp_success(resp)
      set_user_settings # load user settings to session as settings may have changed already

      # check if any erp user change request is found
      if params['erp_user_id'] != params['erp_user_id_original']
        begin
          postdata = {}
          postdata['erpuserid'] = params['erp_user_id']
          resp = NsiServices.post(NSI_SERVICE_ERP_USER, { 'userid' => get_login, 'password' => get_pwd }, postdata)
          if resp['returndata']['data'] == 'erperror'
            log('TnB user ID update failed due to TnB system unavailability')
            flash.now[:error] = get_localized_text(USER_SETTING_ERP_ID_SAVE_ERROR, true)
          elsif resp['returndata']['data'] == 'duplicate'
            log('TnB User ID already exists')
            flash.now[:error] = get_localized_text(USER_SETTING_ERP_ID_DUPLICATE_ERROR + ': ' + params['erp_user_id'], true)
          elsif resp['returndata']['data'] == 'false'
            log('TnB user ID update failed')
            flash.now[:error] = get_localized_text(USER_SETTING_CHANGE_ERROR, true)
          else
            # update erp user ID to local variable
            @erp_user_id = params['erp_user_id']
            flash.now[:success] = get_localized_text(USER_SETTING_CHANGE_SUCCESS, true)
          end
        rescue Exceptions::OperationNotAuthorized => exception
          # #ERP->TnB
          # Robert
          # 07-16-2013
          ##
          log_exception_text('TnB user ID update failed: ' + OPERATION_NON_AUTHORIZED_MESSAGE)
          flash.now[:fatalerror] = get_localized_text(OPERATION_NON_AUTHORIZED_MESSAGE, true)
        rescue Exception => e
          # #ERP->TnB
          # Robert
          # 07-16-2013
          ##
          log_exception_text('Tnb user ID update failed: ' + e.message)
          flash.now[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
        end
      else
        flash.now[:success] = get_localized_text(USER_SETTING_CHANGE_SUCCESS, true)
      end

    else
      flash.now[:error] = get_localized_text(USER_SETTING_CHANGE_ERROR, true)
    end
  rescue Exceptions::OperationNotAuthorized => exception
    log_exception_text('User setting update failed: ' + OPERATION_NON_AUTHORIZED_MESSAGE)
    flash.now[:fatalerror] = get_localized_text(OPERATION_NON_AUTHORIZED_MESSAGE, true)
  rescue Exception => e
    log_exception_text('User setting update failed: ' + e.message)
    flash.now[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
  end

  def make_post_data(postdata, data)
    i = 1
    data.each do |key, value|
      postdata['key' + i.to_s] = key
      postdata['value' + i.to_s] = value
      i += 1
    end
  end

  def set_localization_texts
    @localData = {}

    @localData['change_user_setting']  = get_localized_text('Change user setting', true)
    @localData['save_user_setting']    = get_localized_text('Save user setting', true)
    @localData['save']                 = get_localized_text('Save', true)
    @localData['setting_key']          = get_localized_text('Setting Key', true)
    @localData['value']                = get_localized_text('Value', true)
    @localData['valid_page_size_info'] = get_localized_text('(N.B. Valid page size is from 1 to 1000)', true)
  end
end
