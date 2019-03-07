require 'register_utils'
require 'exceptions'

class RegistersController < BaseController
  def index
    set_view_properties
    render 'index'
  end

  def new

    # TODO: Refact01

    if signed_in? # if already signed in then return to home page
      redirect_to('/homes')
      return
    end
    set_view_properties
    # @usersignup = Register.new
    # render_new @usersignup
    render_new Register.new
  end

  def create
    new_user = Register.new(params[:register])
    
    if verify_recaptcha
      message = new_user.validate

      # TODO: Look into.

      if message == ''
        status = post_user(new_user)
        if status == true
          # UserMailer.welcome_email(new_user).deliver
          flash[:success] = USER_REG_SUCCESS_MESSAGE
          redirect_to :root
        else
          render_new new_user
        end
      else
        flash.now[:notice] = message
        render_new new_user
      end
    else
      flash.delete(:recaptcha_error) # get rid of the recaptcha error being flashed by the gem.
      flash.now[:error] = 'Captcha is incorrect. Please try again.'
      render_new new_user
    end
  end

  def render_new(register)
    @usersignup = register
    set_view_properties
    render 'index'
  end

  private

  def set_view_properties
    @menu             = 'signup'
    @title            = 'Sign Up'
    @pageheader       = @title
    @pageheader_image = 'userlogin.png'
    set_menu_labels
  end

  def show_error(message, type)
    flash.now[type] = message
    set_view_properties
    render 'new'
  end

  def post_user(u)
    postdata = {}
    # postdata.merge!({"userreg" => "userreg"})
    RegisterUtils.make_register_post_data(postdata, u) unless u.nil?
    
    resp = NsiServices.post(NSI_SERVICE_USER_REG, { 'userreg' => 'userreg' }, postdata)
    
    # TODO: Look into.

    if NsiServices.is_resp_success(resp)
      return true
    else
      log('Cannot update user: ' + NsiServices.resp_message(resp))
      # flash[:error] = get_localized_text( NsiServices.resp_message(resp) , true )
      flash.now[:error] = get_localized_text(NsiServices.resp_message(resp), true)
      return false
    end
  rescue Exceptions::OperationNotAuthorized => exception
    log_exception_text('Cannot update user: ' + OPERATION_NON_AUTHORIZED_MESSAGE)
    flash[:fatalerror] = get_localized_text(OPERATION_NON_AUTHORIZED_MESSAGE, true)
    return false, nil
  rescue Exception => e
    log_exception_text('Cannot update user: ' + e.message)
    flash[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
    return false, nil
  end
end
