require 'nsi_services'
class Auth < Tableless
  column :id, :string
  column :login, :string
  column :password, :string
  column :name, :string

  attr_accessible :id, :login, :password, :name

  validates :id, :presence => true
  validates :login, :presence => true
  validates :password, :presence => true

  def self.authenticate(l, p)
    begin
      return NsiServices.get_auth(NsiServices.get(NSI_SERVICE_LOGIN, {'userid' => l, 'password' => p}), l, p)
    rescue Exceptions::ServiceNotAuthorized => exception
      log_exception_text("User authenticaton failed: " + GENERIC_NON_AUTHORIZED_MESSAGE)
      flash.now[:fatalerror] = get_localized_text(GENERIC_NON_AUTHORIZED_MESSAGE, true)
      return nil
    rescue Exception=>e
      log_exception_text("User authenticaton failed: " + e.message)
      flash.now[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
      return nil
    end
  end

  def self.authenticate_with_token(l, p, n, id)
    l.nil? || l == '' || p.nil? || p == '' ? nil : Auth.new(:login => l, :password => p, :name => n, :id => id)
  end
end