class SubscriptionModel < Tableless
  column :id, :string
  column :subscription_model, :string
  column :subscription_days, :string
  column :subscription_price, :float
  column :subscription_total_price, :float
  column :subscription_userlist, :string
  attr_accessible :id, :subscription_model, :subscription_price, :subscription_days, :subscription_total_price, :subscription_userlist
  def self.get(arr)
    return nil if arr.nil? || arr.count == 0
    s = SubscriptionModel.new
    s.id = arr[0]
    s.subscription_model = arr[1]
    s.subscription_days = arr[2]
    s.subscription_price = arr[3]
    s
  end
end
