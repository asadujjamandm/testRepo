class Timecard < Tableless
  column :id, :string
  column :matter_id, :string
  column :template, :string
  column :description, :string
  column :client_id, :string
  column :timekeeper_id, :string
  column :hours, :string
  column :units, :string
  column :hhmm, :string
  column :date, :string
  column :activity_id, :string
  column :ledger_id, :string
  column :bill_status, :string
  column :tax_id, :string
  column :task_id, :string
  column :depaprtment_id, :string
  column :location_id, :string
  column :message, :string
  column :approved, :string
  column :created_date, :string
  column :modified_date, :string
  column :matter_number, :string
  column :client_number, :string
  column :timekeeper_number, :string
  column :posted, :string
  column :is_dirty, :boolean
  column :is_dirty_confirmed, :boolean
  column :timekeeper_name, :string
  column :user_id, :string
  column :user_name, :string
  column :internal_comment, :string
  column :client_name, :string
  column :matter_name, :string
  column :timekeeper_name, :string
  column :is_cached, :boolean
  column :activity_desc, :string
  column :activity_code, :string


  attr_accessible :id, :matter_id, :template, :description, :client_id, :timekeeper_id, :hours, :units, :hhmm, :date,
                  :activity_id, :ledger_id, :bill_status, :tax_id, :task_id, :department_id, :location_id, :message,
                  :approved, :created_date, :modified_date, :matter_number, :client_number, :timekeeper_number, :posted,
                  :is_dirty, :is_dirty_confirmed, :timekeeper_name, :user_id, :user_name, :internal_comment,
                  :client_name, :matter_name,:timekeeper_name, :is_cached, :activity_code, :activity_desc

  def self.get(arr)
    return nil if arr.nil? || arr.count == 0

    t                    = Timecard.new
    t.id                 = arr[0]
    t.matter_id          = arr[1]
    t.template           = arr[2]
    t.description        = arr[3]
    t.client_id          = arr[4]
    t.timekeeper_id      = arr[5]
    t.hours              = arr[6]
    t.units              = arr[7]
    t.hhmm               = arr[8]
    t.date               = arr[9]
    t.activity_id        = arr[10]
    t.ledger_id          = arr[11]
    t.bill_status        = arr[12]
    t.tax_id             = arr[13]
    t.task_id            = arr[14]
    t.depaprtment_id     = arr[15]
    t.location_id        = arr[16]
    t.message            = arr[17]
    t.approved           = arr[18]
    t.posted             = arr[19]
    t.is_dirty           = false
    t.is_dirty_confirmed = false
    t.matter_number      = arr[20]
    t.client_number      = arr[21]
    t.timekeeper_number  = arr[22]
    t.user_id            = arr[23]
    t.internal_comment   = arr[24]
    t.activity_code      = arr[25]
    t.created_date       = arr[26]
    t.modified_date      = arr[27]
    t.client_name        = arr[28]
    t.matter_name        = arr[29]
    t.timekeeper_name    = arr[30]
    t.activity_desc      = arr[31]
    t.user_name          = arr[32] if arr.length >= 32

    return t
  end

  def validate( date_format )   #local date_format

    message = ''

    message += ' Matter'if matter_id.nil? || matter_id == ''

    if client_id.nil? || client_id == ''
      message += ',' if message.size > 0
      message += ' Client'
    end

    if timekeeper_id.nil? || timekeeper_id == ''
      message += ',' if message.size > 0
      message += ' Timekeeper'
    end

    begin
      date1 = DateTime.strptime(date , date_format) #test if the date is in valid format to try to parse it in local date format
      date2 = DateTime.strptime('2000-1-1', '%Y-%d-%m')

      message += ' Date' if date1 < date2  #for example, if date is too old such as 0011 century instead of 2011 century then
    rescue Exception=>e
      log_exception_text("Invalid date to parse: " + e.message)
      message += ' Date'
    end

    #    if template.nil? || template == ''
    #      if message.size > 0
    #        message+=','
    #      end
    #      message+=' Template'
    #    end
    #    if description.nil? || description == ''
    #      if message.size > 0
    #        message+=','
    #      end
    #      message+=' Description'
    #    end
    message
  end
end