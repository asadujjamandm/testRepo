module Utils
  def self.strip_str(str)
    str.nil? || str.strip == '' || str.strip == 'null' ? '' : filter_service_data(str.strip)
  end

  def self.filter_service_data(data)
    nil if data.nil?
    data.gsub('[comma]', ',').gsub('<', '').gsub('>', '')
  end

  def self.strip_time_ms(time)
    begin
      time.nil? ? '' : time[0..time.size-3]
    rescue Exception => e
      log_exception_text( "Error while stripping time: " + e.message )
      ''
    end
  end

  def self.log_exception(exception)
    Rails.logger.error '[EXCEPTION]'+DateTime.now.to_s+': '+exception.message
  end

  def self.log_exception_text( message )
    Rails.logger.error '[EXCEPTION]'+DateTime.now.to_s+': '+ message
  end

  def self.log(message)
    Rails.logger.error '[WARNING]'+DateTime.now.to_s+': '+ message
  end

  #this method is used for displaying time only, not for editing on a text field
  def self.get_time_from_seconds(seconds)
    seconds2 = seconds.to_s #this code is added for solving some version problem while deploying
    #Time.at(seconds2.to_i).gmtime.strftime('%R:%S').to_s
    time = Time.at(seconds2.to_i).gmtime
    if seconds >= 86400                            #added 8.10.15 to prevent total hours being rounded at 24 hours in pdf report
      #hr_reminder = seconds % 3600
      hr_original = seconds / 3600
      #hour = hr_original + hr_reminder
      hour = hr_original
    else
      hour = time.strftime('%H').to_i
    end
    #hour = time.strftime('%H').to_i
    return hour.to_s + ":" + time.strftime('%M')
  end

  #this method is used for editing time on a text field
  def self.get_time_from_seconds_formatted(seconds)
    seconds2 = seconds.to_s #this code is added for solving some version problem while deploying
    time = Time.at(seconds2.to_i).gmtime
    return time.strftime('%H') + ":" + time.strftime('%M')
  end

  #this method is not used but kept if needed for future
  def self.get_time_from_seconds_with_second(seconds)
    seconds2 = seconds.to_s #this code is added for solving some version problem while deploying
    Time.at(seconds2.to_i).gmtime.strftime('%R:%S').to_s
  end

  def self.get_seconds_from_time(time)
    return 0 if time.nil? || time==''
    t=time.split(':')
    (t[0].to_i*3600)+(t[1].to_i*60)+t[2].to_i
  end

  def self.get_seconds_from_minute(minute)
    return 0 if minute.nil? || minute == ''
    minute.to_i * 60;
  end

  def self.get_seconds_from_hour(hour)
    return 0 if hour.nil? || hour == ''
    hour.to_i * 60 * 60;
  end

  def self.get_minutes_from_second(second)
    return 0 if second.nil? || second == ''
    second.to_i / 60
  end

  def self.get_hours_from_second(second)
    return 0 if second.nil? || second == ''
    second.to_i / 3600
  end

  def self.get_today
    #Date.today.strftime('%Y-%m-%d')
    Date.today
  end

  def self.get_day_week_ago(week)
    #week.week.ago.to_date.strftime('%Y-%m-%d')
    week.week.ago.to_date
  end

  def self.get_first_day_of_current_month
    Date.today.at_beginning_of_month
  end

  def self.get_last_day_of_current_month
    Date.today.at_end_of_month
  end

  def self.get_first_day_of_current_year
    Date.today.at_beginning_of_year
  end

  def self.get_first_day_of_week
    Date.today.beginning_of_week
  end

  def self.get_last_day_of_week
    Date.today.end_of_week
  end

  def self.get_first_day_of_last_week
    (Date.today.beginning_of_week - 1).beginning_of_week
  end

  def self.get_last_day_of_last_week
    (Date.today.beginning_of_week - 1).end_of_week
  end

  def self.get_units_value(units, unit_arr, unit_type_arr)
    return 0, '' if units.nil? || units == '' || units == '0' || units == 0
    begin
      u=units.to_i
      if (u % 3600) <= 0
        h=Utils.get_hours_from_second(u)
        if unit_arr.find { |v| v == h }.nil?
          return get_minutes_from_second(u), unit_type_arr[1]
        else
          return h, unit_type_arr[1]
        end
      elsif (u % 60) <= 0
        m=get_minutes_from_second(u)
        if unit_arr.find { |v| v == m }.nil?
          raise 'invalid value'
          #return u, unit_type_arr[0]
        else
          return m, unit_type_arr[0]
        end
      else
        #return u, unit_type_arr[0]
        raise 'invalid value'
      end
    rescue Exception=>e
      log_exception_text ( "Error while getting unit value: " + e.message )
      return 0, '';
    end
  end

  def self.get_units_value_formatted(units, unit_arr, unit_type_arr)
    unit_value, unit_type = get_units_value units, unit_arr, unit_type_arr
    return unit_value.to_s + ' ' + (unit_type.length > 0 ? unit_type[0].to_s.downcase : unit_type) #this code(unit_value.to_s instead of unit_value) is added for solving some version problem while deploying
  end


  def self.get_calendar_day_list()

    calendar_day_list = {}

    arr = { "calendar_start_day_id" => "1", "calendar_start_day" => "Sunday" }
    one_day = CalendarStartDay.get(arr)
    calendar_day_list[ one_day.calendar_start_day_id ] = one_day

    arr = { "calendar_start_day_id" => "2", "calendar_start_day" => "Monday" }
    one_day = CalendarStartDay.get(arr)
    calendar_day_list[ one_day.calendar_start_day_id ] = one_day

    arr = { "calendar_start_day_id" => "3", "calendar_start_day" => "Tuesday" }
    one_day = CalendarStartDay.get(arr)
    calendar_day_list[ one_day.calendar_start_day_id ] = one_day

    arr = { "calendar_start_day_id" => "4", "calendar_start_day" => "Wednesday" }
    one_day = CalendarStartDay.get(arr)
    calendar_day_list[ one_day.calendar_start_day_id ] = one_day

    arr = { "calendar_start_day_id" => "5", "calendar_start_day" => "Thursday" }
    one_day = CalendarStartDay.get(arr)
    calendar_day_list[ one_day.calendar_start_day_id ] = one_day

    arr = { "calendar_start_day_id" => "6", "calendar_start_day" => "Friday" }
    one_day = CalendarStartDay.get(arr)
    calendar_day_list[ one_day.calendar_start_day_id ] = one_day

    arr = { "calendar_start_day_id" => "7", "calendar_start_day" => "Saturday" }
    one_day = CalendarStartDay.get(arr)
    calendar_day_list[ one_day.calendar_start_day_id ] = one_day

    return calendar_day_list

  end

  def self.format_single_calendar_data( a_number )

    if( a_number.nil? )
      return "0:00"
    end

    hours = (a_number.to_f)  # / 60.0

    #return '%.2f' %  hours

    hour = (Integer(hours / 60)).to_s
    #if( hour.length == 1 )
    #  hour = "0" + hour
    #end
    minute = (Integer( hours % 60 )).to_s
    if( minute.length == 1 )
      minute = "0" + minute
    end
    return hour + ":" + minute

  end

  #returns a blank string from a nil parameter and returns actual value if not nil
  def self.get_string_non_nil_value( text )
    if( text.nil? )
      return ''
    else
      return text
    end
  end

  #this method is used for client, matter and timekeeper. To get the full display from display name and number
  def self.get_display_name( name_text, number_text )
    if( name_text.nil? && number_text.nil? )
      return nil
    else
      return get_string_non_nil_value( number_text ) + " - " + get_string_non_nil_value( name_text )
    end
  end

  #this method takes a string of date in a common format and converts(parse) it into a date object Year-Month-Day
  def self.parse_date_in_standard_format( date_string )
    date1 = DateTime.strptime( date_string, "%Y-%m-%d")
    return date1
  end

  def self.get_seconds_from_unit( units, unit_type )

    units_in_number = units.to_i

    if( unit_type == 'Hour' )
       return ( 60 * 60 * units_in_number )
    elsif( unit_type == 'Minute' )
       return ( 60 * units_in_number )
    elsif( unit_type == 'Second' )
       return ( units_in_number )
    else
      raise 'invalid parameter unit type'
    end

  end

  #get bill hours from work hours( according to unit)
  def self.get_bill_hours_from_work_hours( hours_string, units_string )
    hours = hours_string.to_i
    units = units_string.to_i
    if( hours == 0 || units == 0 )
      return hours
    else
      remainder = ( hours % units )
      if( remainder == 0 )
        return hours
      else
        hours = hours + ( units - remainder )
        return hours
      end
    end
  end

end