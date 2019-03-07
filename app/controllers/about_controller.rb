class AboutController < BaseController
  # developed by Wasiqul Islam at 28 Aug, 2011

  def index
    if session[SESSION_USER_SUBSCRIPTION_REMAIN_DAYS_ERRORCODE].to_s == '8080'
      redirect_to('/subscriptions')
      return
    end
    @version      = APP_VERSION
    @release_date = APP_RELEASE_DATE
    @instance     = APP_INSTANCE

    set_view_properties('About WIPTime')
  end

  def set_view_properties(title)
    @menu             = 'about'
    @title            = get_localized_text(title, true)
    @pageheader       = get_localized_text(title, true)
    @pageheader_image = 'wip.png'
    set_menu_labels
    set_localization_texts
  end

  def set_localization_texts
    @localData = {}

    @localData['application_name']   = get_localized_text('WIPTime', true)
    @localData['version']            = get_localized_text('Version:', true)
    @localData['revision']           = get_localized_text('Revision:', true)
    @localData['release_date']       = get_localized_text('Release Date:', true)
    @localData['release_note_label'] = get_localized_text('Release Note:', true)
    @localData['instance']           = get_localized_text('Instance:', true)
    @localData['phone']              = get_localized_text('Phone:', true)
   end
end
