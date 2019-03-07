require 'user_utils'
require 'exceptions'

class ChangePasswordController < BaseController
  before_filter :authenticate

  def index
    if session[SESSION_USER_SUBSCRIPTION_REMAIN_DAYS_ERRORCODE].to_s == '8080'
      redirect_to('/subscriptions')
      return
    end
    set_view_properties
  end

  def update
    if params[:password].nil?
      redirect_to action: 'index'
      return
    end

    set_view_properties

    # TODO: Rewrite 

    if !params[:password].nil?
      changed_password = make_change_password params[:password]
      if changed_password.old_password != get_pwd
        flash.now[:error] = get_localized_text(PASSWORD_CHANGE_OLD_PWD_MISMATCH, true)
      elsif changed_password.new_password != changed_password.confirmed_password
        flash.now[:error] = get_localized_text(PASSWORD_CHANGE_NEW_PWD_MISMATCH, true)
      else
        # current_user = get_current_user
        # if current_user.nil?
        #  flash.now[:error] = get_localized_text( GENERIC_FATAL_ERROR_MESSAGE , true )
        # else
        # current_user.password = changed_password.new_password
        auth = session[:remember_token]
        post_password(changed_password, auth)
        # end
      end
    else
      flash.now[:error] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
    end
    render 'index'
  end

  private

  def set_view_properties
    @menu             = 'preference'
    @title            = get_localized_text('Change Password', true)
    @pageheader       = @title
    @pageheader_image = 'userlogin.png'
    set_menu_labels
    set_localization_texts
  end

  def make_change_password(params_password)
    changed_password = ChangePassword.new
    
    unless params_password.nil?
      changed_password.old_password = params_password[:old]
      changed_password.new_password = params_password[:new]
      changed_password.confirmed_password = params_password[:confirmed]
    end
    
    changed_password
  end

  # def get_current_user
  #  begin
  #    return NsiServices.get_users(NsiServices.get(NSI_SERVICE_USER, {'userid' => get_login, 'password' => get_pwd}, {'id' => get_id})).first[1]
  #  rescue Exception => e
  #    log_exception e
  #    return nil
  #  end
  # end

  def make_post_data(postdata, changed_password)
    # postdata.merge!({"id" => u.id})
    postdata['oldpassword'] = changed_password.old_password
    postdata.merge!('password' => changed_password.new_password)
  end

  def post_password(changed_password, auth)
    postdata = {}
    make_post_data(postdata, changed_password)
    
    resp = NsiServices.post('ChangePassword', { 'userid' => get_login, 'password' => get_pwd }, postdata)
    
    if NsiServices.is_resp_success(resp)
      # sign_out
      sign_in(Auth.new(login: auth[0], password: changed_password.new_password, name: auth[2], id: auth[3]))
      flash.now[:success] = get_localized_text(PASSWORD_CHANGE_SUCCESS, true)
    else
      log('Password change invalid trial. User: ' + get_login + '.')
      flash.now[:error] = get_localized_text(PASSWORD_CHANGE_ERROR, true)
    end
  rescue Exceptions::OperationNotAuthorized => exception
    log_exception_text('Password changing failed: ' + OPERATION_NON_AUTHORIZED_MESSAGE)
    flash.now[:fatalerror] = get_localized_text(OPERATION_NON_AUTHORIZED_MESSAGE, true)
  rescue Exception => e
    log_exception_text('Password changing failed: ' + e.message)
    flash.now[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
  end

  def set_localization_texts
    @localData = {}

    @localData['change_password']  = get_localized_text('Change Password', true)
    @localData['old_password']     = get_localized_text('Old password', true)
    @localData['new_password']     = get_localized_text('New password', true)
    @localData['confirm_password'] = get_localized_text('Confirm password', true)
  end
end
