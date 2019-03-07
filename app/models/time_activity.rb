class TimeActivity < Tableless
  column :txn_date, :string
  column :type, :string
  column :reference_no, :string
  column :reference_id, :string
  column :customer_ref, :string
  column :customer_id, :string
  column :department_ref, :string
  column :department_id, :string
  column :item_ref, :string
  column :item_id, :string
  column :class_ref, :string
  column :class_id, :string
  column :hourly_rate, :string
  column :break_hour, :string
  column :break_min, :string
  column :hours, :string
  column :minute, :string
  column :taxable, :string

  attr_accessible :txn_date, :type, :reference_no, :reference_id, :oauth_token, :customer_ref, :customer_id, :department_ref, :department_id, :item_ref, :item_id, :class_ref, :class_id, :hourly_rate, :break_hour, :break_min, :hours, :minute, :taxable

  #   def self.get(arr)
  #     return nil if arr.nil? || arr.count == 0
  #     u = TimeActivity.new
  #     u.txn_date = arr[0]
  #     u.type = arr[1]
  #     u.vendor_ref = arr[2]
  #     u.employee_ref = arr[3]
  #     u.customer_ref = arr[4]
  #     u.department_ref = arr[5]
  #     u.item_ref = arr[6]
  #     u.class_ref = arr[7]
  #     u.hourly_rate = arr[8]
  #     u.break_hour = arr[9]
  #     u.break_min = arr[10]
  #     u.hours = arr[11]
  #     u.minute = arr[12]
  #     return u
  #   end

  private

  def add_message(message, new_message)
    s = ''
    s = ', ' unless message.empty?
    s += new_message
    s
  end
end
