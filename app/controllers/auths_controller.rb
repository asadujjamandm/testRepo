class AuthsController < BaseController
  before_filter :authenticate, except: [:new, :create]

  def new
    if signed_in? # if already signed in then return to home page
      if session[SESSION_USER_SUBSCRIPTION_REMAIN_DAYS_ERRORCODE].to_s != '8080'
        redirect_to('/homes')
        return
      else
        redirect_to('/subscriptions')
        return
      end
    end

    set_view_properties
    @auth = Auth.new
  end

  def create
    if signed_in? # if already signed in then return to home page
      if session[SESSION_USER_SUBSCRIPTION_REMAIN_DAYS_ERRORCODE].to_s != '8080'
        redirect_to('/homes')
        return
      else
        redirect_to('/subscriptions')
        return
      end
    end

    if params['auth'].nil? || params['auth']['login'].nil? || params['auth']['password'].nil?
      params['auth']             = {}
      params['auth']['login']    = ''
      params['auth']['password'] = ''
    end

    @auth = Auth.new(login: params[:auth][:login])

    begin
      t_auth = Auth.authenticate(params[:auth][:login], params[:auth][:password])
      
      if t_auth.nil?
        log('#####*****#####------------------------------- Invalid login/password entered. User: ' + params[:auth][:login] + ' Password: ' + params[:auth][:password])
        show_error('Invalid login/password combination', :error)
      else
        sign_in t_auth
        set_user_settings
        load_localized_data
        redirect_back_or(homes_path)
      end
    rescue Exception => e
      log_exception_text ('Login failed: ' + e.message)
      show_error(GENERIC_ERROR_MESSAGE, :fatalerror)
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end

  private

  def set_view_properties
    @menu             = 'signin'
    @title            = 'Log in'
    @pageheader       = @title
    @pageheader_image = 'userlogin.png'
    set_menu_labels
  end

  def show_error(message, type)
    flash.now[type] = message
    set_view_properties
    render 'new'
  end
end
