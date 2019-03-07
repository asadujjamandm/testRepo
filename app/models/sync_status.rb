class SyncStatus < Tableless
  column :type, :string
  column :item, :string
  column :last_sync, :string

  attr_accessible :type, :item, :last_sync

  def self.get(arr)
    return nil if arr.nil? || arr.count == 0
    s           = SyncStatus.new
    s.type      = arr[0]
    s.item      = arr[1]
    s.last_sync = arr[2]
    
    return s
  end
end