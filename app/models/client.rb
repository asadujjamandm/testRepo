class Client < Tableless
  column :id, :string
  column :client_number, :string
  column :client_name, :string
  column :display_name, :string
  column :business_address_id, :string
  column :bill_address_id, :string
  column :mailing_address_id, :string
  column :open_date, :string
  column :close_date, :string
  column :is_active, :string
  column :default_time_tncrement, :string
  column :related_client_id, :string
  column :contact_id, :string
  column :business_type_id, :string
  column :credit_terms_id, :string
  column :client_rate_id, :string
  column :cl_udf0, :string
  column :cl_udf1, :string
  column :cl_udf2, :string
  column :cl_udf3, :string
  column :cl_udf4, :string
  column :cl_udf5, :string
  column :cl_udf6, :string
  column :cl_udf7, :string
  column :cl_udf8, :string
  column :cl_udf9, :string
  column :created_date, :string
  column :modified_date, :string
  column :user_id, :string

  attr_accessible :id, :client_number, :client_name, :display_name, :business_address_id, :bill_address_id, :mailing_address_id,
                  :open_date, :close_date, :is_active, :default_time_tncrement, :related_client_id, :contact_id, :business_type_id,
                  :credit_terms_id, :client_rate_id, :cl_udf0, :cl_udf1, :cl_udf2, :cl_udf3, :cl_udf4, :cl_udf5, :cl_udf6, :cl_udf7,
                  :cl_udf8, :cl_udf9, :created_date, :modified_date, :user_id

  def validate(_is_new)
    message = ''
    message += ' Client Number' if client_number.nil? || matter_id == ''

    # TODO: Review this.

    if client_name.nil? || client_id == ''
      message += ',' unless message.empty?
      message += ' Client Name'
    end
    if display_name.nil? || timekeeper_id == ''
      message += ',' unless message.empty?
      message += ' Display Name'
    end
    if is_active.nil? || timekeeper_id == ''
      message += ',' unless message.empty?
      message += ' isActive'
    end
    if message != ''
      return 'Following field(s) are required: ' + message
    else
      return message
    end
  end

  def self.get(arr)
    return nil if arr.nil? || arr.count == 0
    c                        = Client.new
    c.id                     = arr[0]
    c.client_number          = arr[1]
    c.client_name            = arr[2]
    c.display_name           = arr[3]
    c.business_address_id    = arr[4]
    c.bill_address_id        = arr[5]
    c.mailing_address_id     = arr[6]
    c.open_date              = arr[7]
    c.close_date             = arr[8]
    c.is_active              = arr[9]
    c.default_time_tncrement = arr[10]
    c.related_client_id      = arr[11]
    c.contact_id             = arr[12]
    c.business_type_id       = arr[13]
    c.credit_terms_id        = arr[14]
    c.client_rate_id         = arr[15]
    c.cl_udf0                = arr[16]
    c.cl_udf1                = arr[17]
    c.cl_udf2                = arr[18]
    c.cl_udf3                = arr[19]
    c.cl_udf4                = arr[20]
    c.cl_udf5                = arr[21]
    c.cl_udf6                = arr[22]
    c.cl_udf7                = arr[23]
    c.cl_udf8                = arr[24]
    c.cl_udf9                = arr[25]
    c.created_date           = arr[26]
    c.modified_date          = arr[27]
    c.user_id                = arr[28]
    c
  end
end
