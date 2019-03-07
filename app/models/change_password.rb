class ChangePassword < Tableless
  column :old_password
  column :new_password
  column :confirmed_password

  attr_accessible :old_password, :new_password, :confirmed_password 
end