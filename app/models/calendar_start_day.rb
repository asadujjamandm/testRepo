class CalendarStartDay <  Tableless

  column :calendar_start_day_id
  column :calendar_start_day

  attr_accessible :calendar_start_day_id, :calendar_start_day

  def self.get(arr)
    return nil if arr.nil? || arr.count == 0
    r                       = CalendarStartDay.new
    r.calendar_start_day_id = arr["calendar_start_day_id"]
    r.calendar_start_day    = arr["calendar_start_day"]
    return r
  end

end