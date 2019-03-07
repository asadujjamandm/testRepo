class Matter < Tableless
  column :id, :string
  column :matter_number, :string
  column :matter_name, :string
  column :matter_nick_name, :string
  column :matter_description, :string
  column :narrative, :string
  column :open_date, :string
  column :close_date, :string
  column :is_temp_matter, :string
  column :is_active, :string
  column :is_non_billable, :string
  column :is_no_charge, :string
  column :is_admin, :string
  column :is_pro_bono, :string
  column :is_master, :string
  column :default_time_increment, :string
  column :default_markup, :string
  column :related_matter_id, :string
  column :parent_matter_id, :string
  column :client_contact_id, :string
  column :default_timekeeper_id, :string
  column :supervising_tkpr_id, :string
  column :client_id, :string
  column :client_display, :string
  column :matter_rate_id, :string
  column :matter_language_id, :string
  column :matter_type_id, :string
  column :time_tax_id, :string
  column :cost_tax_id, :string
  column :charge_tax_id, :string
  column :unit, :string
  column :mt_udf0, :string
  column :mt_udf1, :string
  column :mt_udf2, :string
  column :mt_udf3, :string
  column :mt_udf4, :string
  column :mt_udf5, :string
  column :mt_udf6, :string
  column :mt_udf7, :string
  column :mt_udf8, :string
  column :mt_udf9, :string
  column :created_date, :string
  column :modified_date, :string
  column :matter_currency_id, :string
  column :user_id, :string

  attr_accessible :id, :matter_number, :matter_name, :matter_nick_name, :matter_description, :narrative, :open_date,
                  :close_date, :is_temp_matter, :is_active, :is_non_billable, :is_no_charge, :is_admin, :is_pro_bono,
                  :is_master, :default_time_increment, :default_markup, :related_matter_id, :parent_matter_id,
                  :client_contact_id, :default_timekeeper_id, :supervising_tkpr_id, :client_id,:client_display, :matter_rate_id,
                  :matter_language_id, :matter_type_id, :time_tax_id, :cost_tax_id, :charge_tax_id, :unit, :mt_udf0,
                  :mt_udf1, :mt_udf2, :mt_udf3, :mt_udf4, :mt_udf5, :mt_udf6, :mt_udf7, :mt_udf8, :mt_udf9,
                  :created_date, :modified_date, :matter_currency_id, :user_id

  def validate(is_new)
    message = ''

    message += ' ' + session[SESSION_CUSTOM_MATTER] + ' Number' if matter_number.nil? || matter_id == ''

    if matter_name.nil? || client_id == ''
      message += ',' if message.size > 0
      message += ' ' + session[SESSION_CUSTOM_MATTER] + ' Name'
    end

    if matter_nick_name.nil? || timekeeper_id == ''
      message += ',' if message.size > 0
      message += ' Nick Name'
    end

    if client_id.nil? || timekeeper_id == ''
      message += ',' if message.size > 0
      message += ' ' + session[SESSION_CUSTOM_CLIENT] + ''
    end

    if is_active.nil? || timekeeper_id == ''
      message += ',' if message.size > 0
      message += ' isActive'
    end

    return message == '' ? message : 'Following field(s) are required: ' + message
  end

  def self.get(arr)
    return nil if arr.nil? || arr.count == 0
    m = Matter.new
    m.matter_number          = arr[0]
    m.matter_name            = arr[1]
    m.matter_nick_name       = arr[2]
    m.matter_description     = arr[3]
    m.narrative              = arr[4]
    m.open_date              = arr[5]
    m.close_date             = arr[6]
    m.is_temp_matter         = arr[7]
    m.is_active              = arr[8]
    m.is_non_billable        = arr[9]
    m.is_no_charge           = arr[10]
    m.is_admin               = arr[11]
    m.is_pro_bono            = arr[12]
    m.is_master              = arr[13]
    m.default_time_increment = arr[14]
    m.default_markup         = arr[15]
    m.related_matter_id      = arr[16]
    m.parent_matter_id       = arr[17]
    m.client_contact_id      = arr[18]
    m.default_timekeeper_id  = arr[19]
    m.supervising_tkpr_id    = arr[20]
    m.client_id              = arr[21]
    m.matter_rate_id         = arr[22]
    m.matter_language_id     = arr[23]
    m.matter_type_id         = arr[24]
    m.time_tax_id            = arr[25]
    m.cost_tax_id            = arr[26]
    m.charge_tax_id          = arr[27]
    m.unit                   = arr[28]
    m.mt_udf0                = arr[29]
    m.mt_udf1                = arr[30]
    m.mt_udf2                = arr[31]
    m.mt_udf3                = arr[32]
    m.mt_udf4                = arr[33]
    m.mt_udf5                = arr[34]
    m.mt_udf6                = arr[35]
    m.mt_udf7                = arr[36]
    m.mt_udf8                = arr[37]
    m.mt_udf9                = arr[38]
    m.matter_currency_id     = arr[39]
    m.user_id                = arr[41]
    m.id                     = arr[42]
    m.created_date           = arr[43]
    m.modified_date          = arr[44]
    m.client_display         = arr[45]
    
    return m
  end
end