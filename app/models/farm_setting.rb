class FarmSetting < Tableless
  column :setting_id
  column :setting_farm_id
  column :setting_timcard_persistent_days
  column :setting_default_activity_code
  column :setting_default_activity_code_tracked_timecards
  column :farm_name
  column :xml_export_path
  column :sync_enabled

  attr_accessible :setting_id, :setting_farm_id, :setting_timcard_persistent_days, :setting_default_activity_code , :setting_default_activity_code_tracked_timecards, :farm_name, :xml_export_path, :sync_enabled

  def self.get(arr)
    return nil if arr.nil? || arr.count == 0
    r                                 = FarmSetting.new
    r.setting_id                      = arr[0]
    r.setting_farm_id                 = arr[1]
    r.setting_timcard_persistent_days = arr[2]
    
    r.setting_default_activity_code = (arr[3] == nil || arr[3] == '') ? '' : arr[3] + ' - ' + arr[5]
   
    r.setting_default_activity_code_tracked_timecards = (arr[4] == nil || arr[4] == '') ? '' : arr[4] + ' - ' + arr[6] 


    r.xml_export_path = arr[7]
    r.sync_enabled    = arr[8]
    return r
  end
end