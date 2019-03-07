class LocalizedData <  Tableless

  column :key
  column :value
  column :localizedDataID

  attr_accessible :key, :value, :localizedDataID

   def self.get(arr)
    return nil if arr.nil? || arr.count == 0
    r                 = LocalizedData.new
    r.key             = arr[2]
    r.value           = arr[3]
    r.localizedDataID = arr[0]
    
    return r
  end

end