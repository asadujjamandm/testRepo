class Locality <  Tableless

  column :locality_id
  column :label

  attr_accessible :locality_id, :label

  def self.get(arr)
    return nil if arr.nil? || arr.count == 0
    r             = Locality.new
    r.locality_id = arr["id"]
    r.label       = arr["label"]

    return r
  end
end