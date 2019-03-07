module ActivitycodesHelper
  def activitycode_records_of
    @activitycode.count.to_s
  end

  def get_activitycode_status(is_active)
    is_active == 'yes' ? 'Active' : 'Inactive'
  end

  def is_new_activitycode
    @title == @localData['new_activitycode']
  end
end