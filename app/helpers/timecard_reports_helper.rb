module TimecardReportsHelper
  def hide_date_search
    @pageheader != @localData['search_timecards']
  end
end
