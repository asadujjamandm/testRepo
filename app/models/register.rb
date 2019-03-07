class Register < Tableless
  column :id, :string
  column :full_name, :string
  column :email, :string
  column :password, :string
  column :confirmed_password, :string
  column :farm_name, :string
  column :registration_date, :string
  column :has_farm, :string
  column :is_default_farm, :string


  attr_accessible :id, :full_name, :email, :password, :confirmed_password, :farm_name, :registration_date, :has_farm, :is_default_farm
  def validate
    message = ''

    message += add_message(message, ' Name') if full_name.nil? || full_name == ''

    message += add_message(message, ' Email') if email.nil? || email == ''

    message += add_message(message, ' Password') if password.nil? || password == ''

    message += add_message(message, ' Confirmed password') if confirmed_password.nil? || confirmed_password == ''

    # TODO: Revisit this

    if message != ''
      return 'Following field(s) are required: ' + message
    elsif password != confirmed_password
      return "Password doesn't match with confirmed password"
    else
      return message
    end

  end

  def self.get(arr)
    return nil if arr.nil? || arr.count == 0
    u                   = Register.new
    u.id                = arr[0]
    u.full_name         = arr[1]
    u.email             = arr[2]
    u.farm_name         = arr[3]
    u.registration_date = arr[4]
    u.has_farm          = arr[5]
    u.is_default_farm   = arr[6]
    return u
  end

  private

  def add_message(message, new_message)
    s = ''
    s = ', ' if message.size > 0
    s += new_message
    
    return s
  end
end
