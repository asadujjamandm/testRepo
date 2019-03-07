require 'exceptions'

class FarmSettingController < BaseController
  before_filter :authenticate

  def index

    # TODO: Refact01

    if session[SESSION_USER_SUBSCRIPTION_REMAIN_DAYS_ERRORCODE].to_s == '8080'
      redirect_to('/subscriptions')
      return
    end

    unless NsiServices.hasPermission(NSI_SERVICE_FARM_SETTING, 'userid' => get_login, 'password' => get_pwd) # if already signed in then return to home page
      redirect_to('/homes')
      return
    end
    set_view_properties
    fetch_data
  end

  def update
    if params['farm_setting'].nil?
      redirect_to action: 'index'
      return
    end

    post_data(params)

    set_view_properties
    fetch_data
    render 'index'
  end

  private

  def fetch_data

    begin
      @farm_setting = NsiServices.get_timcard_persistent_days(NsiServices.get(NSI_SERVICE_FARM_SETTING, 'userid' => get_login, 'password' => get_pwd, 'firmsettingswebapp' => 'firmsettingswebapp'))
    rescue Exceptions::ServiceNotAuthorized => exception
      log_exception_text('Cannot get firm setting: ' + GENERIC_NON_AUTHORIZED_MESSAGE)
      flash.now[:fatalerror] = get_localized_text(GENERIC_NON_AUTHORIZED_MESSAGE, true)
      @farm_setting = nil
    rescue Exception => e
      log_exception_text('Cannot get firm setting: ' + e.message)
      flash.now[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
      @farm_setting = nil
    end

    @timecard_persistent_days = { '30' => '30', '45' => '45', '60' => '60', '75' => '75', '90' => '90' }
    # @farm_setting.setting_default_activity_code_tracked_timecards = '1101'
  end

  def post_data(inputData)
    postdata = {}
    make_post_data(postdata, inputData)
    resp = NsiServices.post(NSI_SERVICE_FARM_SETTING, { 'userid' => get_login, 'password' => get_pwd, 'farmsetting' => 'farmsetting' }, postdata)
    if NsiServices.is_resp_success(resp)
      flash.now[:success] = get_localized_text(FARM_SETTING_CHANGE_SUCCESS, true)
    else
      log('Firm settings not saved')
      flash.now[:error] = get_localized_text(FARM_SETTING_CHANGE_ERROR, true)
    end
  rescue Exceptions::OperationNotAuthorized => exception
    log_exception_text('Firm settings not saved: ' + OPERATION_NON_AUTHORIZED_MESSAGE)
    flash.now[:fatalerror] = get_localized_text(OPERATION_NON_AUTHORIZED_MESSAGE, true)
  rescue Exception => e
    log_exception_text('Firm settings not saved: ' + e.message)
    flash.now[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
  end

  def make_post_data(postdata, data)
    id                                      = data['farm_setting']['setting_id']
    farm_id                                 = data['farm_setting']['setting_farm_id']
    timecard_persistent_days                = data['farm_setting']['setting_timcard_persistent_days']
    default_activity_code                   = data['farm_setting']['setting_default_activity_code']
    default_activity_code_tracked_timecards = data['farm_setting']['setting_default_activity_code_tracked_timecards']
    xml_export_path                         = data['xml_export_path']
    sync_enabled                            = data['farm_setting']['sync_enabled']
    # farm_name = session[ SESSION_FARM_NAME ]

    postdata['id0']                        = id
    postdata['farmid0']                    = farm_id
    postdata['daysoftimecardinmobicache0'] = timecard_persistent_days
    postdata['defaultactivitycode0']       = default_activity_code.to_s.split(' - ')[0]
    postdata['calltrackingactivitycode0']  = default_activity_code_tracked_timecards.to_s.split(' - ')[0]
    postdata['exportpath0']                = xml_export_path
    postdata.merge!('syncenabled0' => sync_enabled)
    # postdata.merge!( {"farm_name" => farm_name} )
  end

  def set_view_properties
    @menu             = 'admin'
    @title            = get_localized_text('Firm Settings', true)
    @pageheader       = @title
    @pageheader_image = 'settings.png'
    set_menu_labels
    set_localization_texts
  end

  def set_localization_texts
    @localData = {}

    @localData['change_farm_setting']                     = get_localized_text('Change Firm Settings', true)
    @localData['save_farm_setting']                       = get_localized_text('Save Firm Settings', true)
    @localData['save']                                    = get_localized_text('Save', true)
    @localData['timecard_persistent_days']                = get_localized_text('Cache timecards for (days)', true)
    @localData['default_activity_code']                   = get_localized_text('Default Activity Code', true)
    @localData['default_activity_code_tracked_timecards'] = get_localized_text('Default Activity Code for Call Tracking', true)
    @localData['xml_export_path']                         = get_localized_text('Xml Export Path', true)
    @localData['sync_enabled']                            = get_localized_text('Sync Enable', true)
  end
end
