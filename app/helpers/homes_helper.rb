module HomesHelper
  def get_dashboard_status(status)
    status.nil? || status == '' ? 'not available' : status
  end
end
