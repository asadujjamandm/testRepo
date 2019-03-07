class RolePermission < Tableless
  column :id
  column :role_id, :string
  column :service_object_id, :string
  column :operation, :string
  column :permission, :string
  column :description, :string
  column :serial, :string

  attr_accessible :id, :role_id, :service_object_id, :operation, :permission, :description, :serial

  def self.get(arr)
    return nil if arr.nil? || arr.count == 0
    rp                   = RolePermission.new
    rp.role_id           = arr[0]
    rp.service_object_id = arr[1]
    rp.operation         = arr[2]
    rp.permission        = arr[3]
    rp.description       = arr[4]
    rp.serial            = arr[5]
    
    return rp
  end
end