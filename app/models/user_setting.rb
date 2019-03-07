class UserSetting <  Tableless

  column :setting_key
  column :setting_value
  column :setting_id

  attr_accessible :setting_key, :setting_value, :setting_id

   def self.get(arr)
    return nil if arr.nil? || arr.count == 0
    r               = UserSetting.new
    r.setting_key   = arr[2]
    r.setting_value = arr[3]
    r.setting_id    = arr[0]
    
    return r
  end

end
