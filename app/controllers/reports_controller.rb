# require 'prawn'
# require 'prawn/layout'
class ReportsController < BaseController
  before_filter :authenticate

  def index

    # TODO: Refact01

    if session[SESSION_USER_SUBSCRIPTION_REMAIN_DAYS_ERRORCODE].to_s == '8080'
      redirect_to('/subscriptions')
      return
    end
    
    @menu             = 'report'
    @title            = get_localized_text('Reports', true)
    @pageheader_image = 'report.png'
    set_menu_labels
    set_localization_texts
  end

  def set_localization_texts
    @localData = {}

    @localData['timecard_reports'] = get_localized_text('Timecard Reports', true)
    @localData['all_timecards']    = get_localized_text('All Timecards', true)
    @localData['last_four_weeks']  = get_localized_text('Last Four Weeks', true)
    @localData['month_to_date']    = get_localized_text('Month to Date', true)
    @localData['year_to_date']     = get_localized_text('Year to Date', true)
  end
end
