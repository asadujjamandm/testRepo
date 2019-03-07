class NumberFormat <  Tableless

  column :number_format_id
  column :number_format

  attr_accessible :number_format_id, :number_format

   def self.get(arr)
    return nil if arr.nil? || arr.count == 0
    r                  = NumberFormat.new
    r.number_format_id = arr["id"]
    r.number_format    = arr["numberFormat"]
    
    return r
  end

end