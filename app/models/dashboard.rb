class Dashboard < Tableless
  column :last_login_web, :string
  column :last_login_device, :string
  column :total_timecards, :string
  column :non_synced_timecards, :string
  column :non_approved_timecards, :string
  column :hours_this_week, :string
  column :hours_last_week, :string
  column :hours_this_month, :string
  column :last_sync_web, :string
  column :last_sync_device, :string

  column :total_billable_current, :string
  column :total_non_billable_current, :string
  column :total_billable_last_month, :string
  column :total_non_billable_last_month, :string
  column :total_billable_last_month2, :string
  column :total_non_billable_last_month2, :String
  column :days_to_last_bill, :string
  column :last_time_card_date, :string

  attr_accessible :last_login_web, :last_login_device, :total_timecards, :non_synced_timecards,
                  :non_approved_timecards, :hours_this_week, :hours_last_week, :hours_this_month,
                  :last_sync_web, :last_sync_device, :total_billable_current,:total_non_billable_current,
                  :total_billable_last_month, :total_non_billable_last_month, :total_billable_last_month2,
                  :total_non_billable_last_month2, :days_to_last_bill, :last_time_card_date
end