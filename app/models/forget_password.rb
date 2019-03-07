class ForgetPassword < Tableless
  column :email, :string
  column :firm_id, :string
  column :password, :string

  attr_accessible :email, :firm_id, :password


  def validate
    message = ''

    # TODO: just make a nil or empty method

    message += add_message(message, ' Email') if email.nil? || email == ''

    message += add_message(message, ' Firm Id') if firm_id.nil? || firm_id == ''

    return message == '' ? message : 'Following field(s) are required: ' + message
  end

  private

  def add_message(message, new_message)
    s = ''
    s = ', ' if message.size > 0
    s += new_message
    return s
  end
end