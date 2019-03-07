class Quickbook < Tableless
  column :company_id, :string
  column :consumer_token, :string
  column :consumer_token_secret, :string
  column :access_token_expire_date, :string
  column :oauth_token, :string
  column :oauth_token_secret, :string
  column :realmId, :string
  column :oauth_verifier, :string

  attr_accessible :company_id, :consumer_token, :consumer_token_secret, :access_token_expire_date, :oauth_token, :oauth_token_secret, :realmId, :oauth_verifier

  def self.get(arr)
    return nil if arr.nil? || arr.count == 0
    u = Quickbook.new
    u.company_id = arr[0]
    u.consumer_token = arr[1]
    u.consumer_token_secret = arr[2]
    u.access_token_expire_date = arr[3]
    u.oauth_token = arr[4]
    u.oauth_token_secret = arr[5]
    u.realmId = arr[6]
    u.oauth_verifier = arr[7]
    u
  end

  private

  def add_message(message, new_message)
    s = ''
    s = ', ' unless message.empty?
    s += new_message
    s
  end
end
