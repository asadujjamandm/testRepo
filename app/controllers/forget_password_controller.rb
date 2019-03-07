require 'exceptions'
require 'forget_password_utils'

class ForgetPasswordController < BaseController
  def index
    set_view_properties
    render 'index'
  end

  def new
    # TODO: Look into this

    if signed_in? # if already signed in then return to home page
      redirect_to('/homes')
      return
    end
    set_view_properties
    render_new ForgetPassword.new
  end

  def create
    user = ForgetPassword.new(params[:forget_password])

    message = user.validate
   
    # TODO: Review this.

    if message == ''
      random_password = Array.new(10).map { (65 + rand(58)).chr }.join
      user.password = random_password
      status = post_user_password(user)
      if status == true
        # UserMailer.welcome_email(new_user).deliver
        flash[:success] = USER_PASSWORD_SUCCESS_MESSAGE
        redirect_to :root
      else
        render_new user
      end
    else
      flash.now[:notice] = message
      render_new user
    end
  end

  def render_new(user)
    @forgetpassword = user
    set_view_properties
    render 'index'
  end

  private

  def set_view_properties
    @menu             = 'signup'
    @title            = 'Forgot Password'
    @pageheader       = @title
    @pageheader_image = 'userlogin.png'
    set_menu_labels
  end

  def show_error(message, type)
    flash.now[type] = message
    set_view_properties
    render 'new'
  end

  def post_user_password(u)
    postdata = {}
    ForgetPasswordUtils.make_password_post_data(postdata, u) unless u.nil?
    resp = NsiServices.post(NSI_SERVICE_USER_REG, { 'userpasswordreset' => 'userpasswordreset' }, postdata)
    
    if NsiServices.is_resp_success(resp)
      return true
    else
      log('User password can not be updated: ' + NsiServices.resp_message(resp))
      # flash[:error] = get_localized_text( NsiServices.resp_message(resp) , true )
      flash.now[:error] = get_localized_text(NsiServices.resp_message(resp), true)
      return false
    end
  rescue Exceptions::OperationNotAuthorized => exception
    log_exception_text('User password can not be updated: ' + OPERATION_NON_AUTHORIZED_MESSAGE)
    flash[:fatalerror] = get_localized_text(OPERATION_NON_AUTHORIZED_MESSAGE, true)
    return false, nil
  rescue Exception => e
    log_exception_text('User password can not be updated: ' + e.message)
    flash[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
    return false, nil
  end
end
