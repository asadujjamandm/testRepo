class DateFormat <  Tableless

  column :date_format_id
  column :date_format

  attr_accessible :date_format_id, :date_format

   def self.get(arr)
    return nil if arr.nil? || arr.count == 0
    r                = DateFormat.new
    r.date_format_id = arr["id"]
    r.date_format    = arr["dateFormat"]
    return r
  end

end