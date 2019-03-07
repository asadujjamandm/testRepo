class Subscription < Tableless
  belongs_to :subscription_model
  column :id, :string
  column :selected_model_id, :string
  column :selected_model_days, :string
  column :selected_model_name, :string
  column :selected_model_price, :float
  column :notification_params, :text
  column :status, :string
  column :transaction_id, :string
  column :purchased_at, :datetime

  attr_accessible :id, :selected_model_id, :selected_model_days, :selected_model_name, :selected_model_price, :subscription_model, :subscription_price, :subscription_days, :notification_params, :status, :transaction_id, :purchased_at
  def self.get(arr)
    return nil if arr.nil? || arr.count == 0
    s = Subscription.new
    s.id = arr[0]
    s.subscription_model = arr[1]
    s.subscription_days = arr[2]
    s.subscription_price = arr[3]
    s
  end

  serialize :notification_params, Hash
  def paypal_url(return_path)
    values = {
      business: 'merchant@akash.com',
      cmd: '_xclick',
      upload: 1,
      # return: "#{Rails.application.secrets.app_host}#{return_path}",
      return: "https://32eb7f41.ngrok.com#{return_path}",
      invoice: id,
      amount: selected_model_price,
      item_name: selected_model_name,
      item_number: selected_model_id,
      quantity: '1',
      # notify_url: "#{Rails.application.secrets.app_host}/hook"
      notify_url: 'https://32eb7f41.ngrok.com/hook'
    }
    # "#{Rails.application.secrets.paypal_host}/cgi-bin/webscr?" + values.to_query
    'https://www.sandbox.paypal.com/cgi-bin/webscr?' + values.to_query
  end

  private

  def add_message(message, new_message)
    s = ''
    s = ', ' unless message.empty?
    s += new_message
    s
  end
end
