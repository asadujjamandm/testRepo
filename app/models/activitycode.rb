class Activitycode < Tableless
  column :id, :string
  column :activity_code, :string
  column :activity_desc, :string
  column :is_active, :string
  column :code_type, :string

  attr_accessible :id, :activity_code, :activity_desc, :is_active, :code_type

  def validate(is_new)
    message = ''

    # TODO: Yeah, make a new def for this.

    if is_new
      message += add_message(message, ' Activity code') if activity_code.nil? || activity_code == ''
    
      message += add_message(message, ' Activity Description') if activity_desc.nil? || activity_desc == ''
    end

    return message == '' ? message : 'Following field(s) are required: ' + message
  end

  def self.get(arr)
    return nil if arr.nil? || arr.count == 0
    a               = Activitycode.new
    a.id            = arr[0]
    a.activity_code = arr[1]
    a.activity_desc = arr[2]
    a.is_active     = arr[3]
    a.code_type     = arr[4]
    return a
  end

  private

  def add_message(message, new_message)
    s = ''
    s = ', ' if message.size > 0
    s += new_message
    return s
  end
end
