class Timekeeper < Tableless
  column :id, :string
  column :timekeeper_number, :string
  column :user_id, :string
  column :display_name, :string
  column :bill_name, :string
  column :bill_initial, :string
  column :is_active, :string
  column :timekeeper_rate_id, :string
  column :timekeeper_type_id, :string
  column :secretary1_id, :string
  column :secretary2_id, :string
  column :supervisor_id, :string
  column :address_id, :string
  column :location_id, :string
  column :department_id, :string
  column :ledger_id, :string
  column :tK_udf0, :string
  column :tK_udf1, :string
  column :tK_udf2, :string
  column :tK_udf3, :string
  column :tK_udf4, :string
  column :tK_udf5, :string
  column :tK_udf6, :string
  column :tK_udf7, :string
  column :tK_udf8, :string
  column :tK_udf9, :string
  column :created_date, :string
  column :modified_date, :string

  attr_accessible :id, :timekeeper_number, :user_id, :display_name, :bill_name, :bill_initial, :is_active, :timekeeper_rate_id,
                  :timekeeper_type_id, :secretary1_id, :secretary2_id, :supervisor_id, :address_id, :location_id, :department_id,
                  :ledger_id, :tK_udf0, :tK_udf1, :tK_udf2, :tK_udf3, :tK_udf4, :tK_udf5, :tK_udf6, :tK_udf7, :tK_udf8, :tK_udf9,
                  :created_date, :modified_date

  def self.get(arr)
    return nil if arr.nil? || arr.count == 0
    t                    = Timekeeper.new
    t.id                 = arr[0]
    t.timekeeper_number  = arr[1]
    t.user_id            = arr[2]
    t.display_name       = arr[3]
    t.bill_name          = arr[4]
    t.bill_initial       = arr[5]
    t.is_active          = arr[6]
    t.timekeeper_rate_id = arr[7]
    t.timekeeper_type_id = arr[8]
    t.secretary1_id      = arr[9]
    t.secretary2_id      = arr[10]
    t.supervisor_id      = arr[11]
    t.address_id         = arr[12]
    t.location_id        = arr[13]
    t.department_id      = arr[14]
    t.ledger_id          = arr[15]
    t.tK_udf0            = arr[16]
    t.tK_udf1            = arr[17]
    t.tK_udf2            = arr[18]
    t.tK_udf3            = arr[19]
    t.tK_udf4            = arr[20]
    t.tK_udf5            = arr[21]
    t.tK_udf6            = arr[22]
    t.tK_udf7            = arr[23]
    t.tK_udf8            = arr[24]
    t.tK_udf9            = arr[25]
    t.created_date       = arr[26]
    t.modified_date      = arr[27]

    t
  end

  # TODO: Review rest of methods.

  def validate(is_new)
    message = ''
    if is_new
      if timekeeper_number.nil? || timekeeper_number == ''
        message += add_message message, ' Timekeeper Number'
      end
      if display_name.nil? || display_name == ''
        message += add_message message, ' Display Name'
      end
      if bill_name.nil? || bill_name == ''
        message += add_message message, ' Bill Name'
      end
    end
    if message != ''
      return 'Following field(s) are required: ' + message
    else
      return message
    end
  end

  def add_message(message, new_message)
    s = ''
    s = ', ' unless message.empty?
    s += new_message
    s
  end
end
