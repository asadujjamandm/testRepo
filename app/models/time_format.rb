class TimeFormat <  Tableless

  column :time_format_id
  column :time_format

  attr_accessible :time_format_id, :time_format

   def self.get(arr)
    return nil if arr.nil? || arr.count == 0
    r                = TimeFormat.new
    r.time_format_id = arr["id"]
    r.time_format    = arr["timeFormat"]
    
    return r
  end

end
