class User < Tableless
  column :id, :string
  column :name, :string
  column :password, :string
  column :email, :string
  column :is_active, :string
  column :confirmed_password, :string
  column :timekeeper_id, :string
  column :timekeeper_number, :string
  column :timekeeper_name, :string

  attr_accessible :id, :name, :password, :email, :is_active, :confirmed_password, :timekeeper_id, :timekeeper_number, :timekeeper_name

  def validate(is_new)
    message = ''

    message += add_message(message, ' Name') if name.nil? || name == ''

    if is_new
      message += add_message(message, ' Password') if password.nil? || password == ''  
      message += add_message(message, ' Confirmed password') if confirmed_password.nil? || confirmed_password == ''
    end

    # TODO: Revisit this.

    if message != ''
      return 'Following field(s) are required: ' + message
    elsif is_new && password != confirmed_password
      return "Password doesn't match with confirmed password"
    else
      return message
    end
  end

  def self.get(arr)
    return nil if arr.nil? || arr.count == 0
    u                   = User.new
    u.id                = arr[0]
    u.name              = arr[1]
    u.password          = arr[2]
    u.email             = arr[3]
    u.is_active         = arr[4]
    u.timekeeper_id     = arr[5]
    u.timekeeper_number = arr[6]
    return u

  end

  private

  # TODO: This shows up a lot. Refactor?

  def add_message(message, new_message)
    s = ', ' if message.size > 0
    s += new_message

    return s
  end
end
