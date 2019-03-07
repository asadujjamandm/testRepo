require 'utils'
module TimecardsHelper
  def timecard_records_of
    @timecards.count.to_s
  end

  def get_hours
    (0..12).to_a
  end

  def get_units
    #(0..59).to_a
    return [1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 99].to_a
  end

  def get_hh
    (0..23).to_a.map! { |v| '%02d' % v }
  end

  def get_mm
    (0..59).to_a.map! { |v| '%02d' % v }
  end

  def get_selected_hour(hhmm)
    hhmm.split(':')[0] unless hhmm.nil?
  end

  def get_selected_minute(hhmm)
    hhmm.split(':')[1] unless hhmm.nil?
  end

  def format_time(hhmm)
    return nil if hhmm.nil?
    a = hhmm.split(':')
    return a[0] + ':' + a[1]
  end

  def get_bill_statuses(include_blank=false)
    if include_blank
      #['', 'Billable', 'Non-billable', 'Non-chargeable'].to_a
      {"" => "", @localData['billable'] => "Billable" , @localData['non_billable'] => "Non-billable" }
    else
      #['Billable', 'Non-billable', 'Non-chargeable'].to_a
      { @localData['billable'] => "Billable" , @localData['non_billable'] => "Non-billable" }
    end
  end

  def get_approve_statuses
    #['', 'Yes', 'No'].to_a
    {"" => "", @localData['yes'] => "Yes" , @localData['no'] => "No"}
  end

  def get_sync_statuses
    #['', 'Yes', 'No'].to_a
    {"" => "", @localData['yes'] => "Yes" , @localData['no'] => "No"}
  end

  def is_new_timecard
    @title == @localData['new_timecard']
  end

  def is_search_page
    @pageheader.starts_with?('Search')
  end

  def get_unit_types
    ['Minute', 'Hour'].to_a
  end

  def get_units_value(units)
    Utils.get_units_value(units, get_units, get_unit_types)
  end

  def get_units_value_formatted(units)
    Utils.get_units_value_formatted(units, get_units, get_unit_types)
  end

   def get_first_day_of_week
    Utils.get_first_day_of_week
  end

  def get_last_day_of_week
    Utils.get_last_day_of_week
  end

  def get_first_day_of_last_week
    Utils.get_first_day_of_last_week
  end

  def get_last_day_of_last_week
    Utils.get_last_day_of_last_week
  end

  def get_first_day_of_current_month
    Utils.get_first_day_of_current_month
  end

  def get_last_day_of_current_month
    Utils.get_last_day_of_current_month
  end
end