module TimekeeperHelper
  def timekeeper_records_of
    @timekeeper.count.to_s
  end

  def get_timekeeper_status(is_active)
    is_active == 'yes' ? 'Active' : 'Inactive'
  end

  def is_new_timekeeper
    @title == @localData['new_timekeeper']
  end


end