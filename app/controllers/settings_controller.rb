class SettingsController < BaseController
  before_filter :authenticate

  def index

    # TODO: Refact01

    if session[SESSION_USER_SUBSCRIPTION_REMAIN_DAYS_ERRORCODE].to_s == '8080'
      redirect_to('/subscriptions')
      return
    end
    
    @menu             = 'settings'
    @title            = get_localized_text('Settings', true)
    @pageheader_image = 'settings.png'
    set_menu_labels
    set_localization_texts
  end

  def set_localization_texts
    @localData = {}

    @localData['user_Settings']   = get_localized_text('User Settings', true)
    @localData['customize']       = get_localized_text('Customize', true)
    @localData['change_password'] = get_localized_text('Change Password', true)
    @localData['locale']          = get_localized_text('Locale', true)
    @localData['farm_setting']    = get_localized_text('Firm Setting', true)
  end
end
