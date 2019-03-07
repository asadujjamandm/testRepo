class ListItem < Tableless
    column :id, :string
    column :display, :string
    attr_accessible :id, :display

  def self.get(arr)
    return nil if arr.nil? || arr.count == 0
    item         = ListItem.new
    item.id      = arr["Id"]
    item.display = arr["Display"]
    
    return item
  end

end