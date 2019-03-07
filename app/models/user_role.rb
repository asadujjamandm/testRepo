class UserRole < Tableless
  column :id, :string
  column :user_id, :string
  column :role_id, :string
  column :is_role_admin, :string
  column :can_read_all, :string
  column :can_insert_all, :string
  column :can_update_all, :string
  column :can_delete_all, :string
  column :role_name, :string
  column :is_role_active, :boolean

  attr_accessible :id, :user_id, :role_id, :is_role_admin, :can_read_all, :can_insert_all,
                  :can_update_all, :can_delete_all, :role_name, :is_role_active

  def self.get(arr)
    return nil if arr.nil? || arr.count == 0
    ur                = UserRole.new
    ur.id             = arr[0]
    ur.user_id        = arr[1]
    ur.role_id        = arr[2]
    ur.is_role_admin  = arr[3]
    ur.can_read_all   = arr[4]
    ur.can_insert_all = arr[5]
    ur.can_update_all = arr[6]
    ur.can_delete_all = arr[7]
    
    return ur
  end
end
