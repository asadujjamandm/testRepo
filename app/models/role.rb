class Role < Tableless
  column :id, :string
  column :name, :string
  column :desc, :string
  column :is_active, :string

  attr_accessible :id, :name, :desc, :is_active

  def validate()
    message = ''

    message += add_message(message, ' Name') if name.nil? || name == ''

    return message == '' ? message : 'Following field(s) are required: ' + message
  end

  def self.get(arr)
    return nil if arr.nil? || arr.count == 0
    r           = Role.new
    r.id        = arr[0]
    r.name      = arr[1]
    r.desc      = arr[2]
    r.is_active = arr[3]

    return r
  end

  private

  def add_message(message, new_message)
    s = ''
    s = ', ' if message.size > 0
    s += new_message
    
    return s
  end
end