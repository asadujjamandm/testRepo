module AuthsHelper
  def sign_in(auth)
    session[:remember_token] = [auth.login, auth.password, auth.name, auth.id]
    self.current_auth = auth
  end

  def sign_out
    reset_session
    self.current_auth = nil
  end

  def current_auth=(auth)
    @current_auth = auth
  end

  def current_auth
    @current_auth ||= auth_from_remember_token
  end

  def current_auth?(auth)
    auth == current_auth
  end

  def signed_in?
    !current_auth.nil?
  end

  def authenticate
    deny_access unless signed_in?
  end

  def deny_access
    store_location
    redirect_to signin_path
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    clear_return_to
  end

  private
  def auth_from_remember_token
    Auth.authenticate_with_token(*remember_token)
  end

  def remember_token
    session[:remember_token] || [nil, nil, nil, nil]
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def clear_return_to
    session[:return_to] = nil
  end
end