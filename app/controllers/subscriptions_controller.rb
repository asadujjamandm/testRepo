require 'exceptions'
require 'json'

class SubscriptionsController < BaseController
  before_filter :authenticate

  def index
    search_subscriptionmodel
    if NsiServices.hasPermission(NSI_SERVICE_USER, 'userid' => get_login, 'password' => get_pwd) # if already signed in then return to home page
      search_users
      @permitted = 1
    end
    set_view_properties
  end

  def cancel
    redirect_to action: 'index'
  end

  def show
  end

  def notice
    model_id =  params[:model_id]
    user_ids = session[:user_list]
    begin
      if user_ids.nil?
        resp = NsiServices.post(NSI_SERVICE_USERSUB, { 'userid' => get_login, 'password' => get_pwd, 'usersubinsert' => 'usersubinsert' }, 'usersubmodelid' => model_id)
        if NsiServices.is_resp_success(resp)
          flash[:success] = get_localized_text(NsiServices.resp_message(resp), true)
          redirect_to action: 'notify'
        else
          log('Unable to update user: ' + NsiServices.resp_message(resp))
          flash[:error] = get_localized_text(NsiServices.resp_message(resp), true)
          redirect_to action: 'index'
        end
      else
        resp = NsiServices.post(NSI_SERVICE_USERSUB, { 'userid' => get_login, 'password' => get_pwd, 'firmsubinsert' => 'firmsubinsert' }, 'firmsubmodelid' => model_id, 'firmusersubid' => user_ids.map { |_k, v| v.to_s }.join(','))
        session[:user_list] = nil
        if NsiServices.is_resp_success(resp)
          flash[:success] = get_localized_text(NsiServices.resp_message(resp) + '.', true)
          redirect_to action: 'index'
        else
          log('Unable to update user: ' + NsiServices.resp_message(resp))
          flash[:error] = get_localized_text(NsiServices.resp_message(resp), true)
          redirect_to action: 'index'
        end
      end
    rescue Exceptions::OperationNotAuthorized => exception
      log_exception_text('Unable to update user: ' + OPERATION_NON_AUTHORIZED_MESSAGE)
      flash[:fatalerror] = get_localized_text(OPERATION_NON_AUTHORIZED_MESSAGE, true)
    rescue Exception => e
      log_exception_text('Unable to update user: ' + e.message)
      flash[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
    end
  end

  def notify
    set_view_properties
    # sleep(10.0)
    # redirect_to :controller => 'auths', :action => 'destroy'
  end

  def confirm
    search_subscriptionmodel
    @confirm = 1
    selected_model_id = params[:subscription][:subscription_model]

    @dirty_model = get_dirty_model(selected_model_id)
    # @userlist = params[:user]
    session[:user_list] = params[:user]
    # @userlist.map{|k,v| "#{k}=#{v}"}.join(',')
    puts session[:user_list]
    if !session[:user_list].nil?
      @dirty_model.subscription_price = session[:user_list].count * @dirty_model.subscription_price
    else
      @dirty_model.subscription_price = @dirty_model.subscription_price
    end
    set_view_properties
  end

  protect_from_forgery except: [:hook, :notice]
  def hook
    params.permit!
    status = params[:payment_status]
    if status == 'Completed'
      @subscriptions = Subscription.find params[:invoice]
      @subscriptions.update_attributes notification_params: params, status: status, transaction_id: params[:txn_id], purchased_at: Time.now
    end
    render nothing: true
  end

  def create
    search_subscriptionmodel
    selected_model_id = params[:model_id]
    user_list = session[:user_list]
    @dirty_model = get_dirty_model(selected_model_id)
    @subscriptions = Subscription.new
    # @subscriptions.id=@dirty_model.id
    @subscriptions.selected_model_id = @dirty_model.id
    @subscriptions.selected_model_price = @dirty_model.subscription_price.to_f
    if !user_list.nil?
      @subscriptions.selected_model_price = user_list.count * @subscriptions.selected_model_price
    else
      @subscriptions.selected_model_price = @subscriptions.selected_model_price
    end
    @subscriptions.selected_model_name = @dirty_model.subscription_model
    @subscriptions.selected_model_days = @dirty_model.subscription_days
    if @subscriptions.save
      puts @subscriptions
      redirect_to @subscriptions.paypal_url(notice_path(model_id: @subscriptions.selected_model_id))
    else
      render :index
    end
    # set_view_properties
  end

  def get_dirty_model(model_id)
    dirty_model_id = model_id
    unless dirty_model_id.nil?
      @subscriptions_model.find { |_k, v| v.id == dirty_model_id }[1]
    end
  end

  def search_subscriptionmodel
    @subscriptions_model = NsiServices.get_subscriptions(NsiServices.get(NSI_SERVICE_USERSUB, 'userid' => get_login, 'password' => get_pwd, 'submodelget' => 'submodelget'))

  rescue Exception => e
    log_exception_text('subscription search failed: ' + e.message)
    flash[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
    @subscriptions_model = {}
  end

  private

  def search_users
    @search_object = session[:user_search_object]
    begin
      if !@search_object.nil?
        @users = NsiServices.get_users(NsiServices.get(NSI_SERVICE_USER, { 'userid' => get_login, 'password' => get_pwd, 'usereditlist' => 'usereditlist' }, 'roleid' => @search_object.role_id, 'isactive' => @search_object.is_active))
      else
        @users = NsiServices.get_users(NsiServices.get(NSI_SERVICE_USER, { 'userid' => get_login, 'password' => get_pwd }, 'usereditlist' => '10'))
      end
    rescue Exceptions::ServiceNotAuthorized => exception
      log_exception_text('User search failed: ' + GENERIC_NON_AUTHORIZED_MESSAGE)
      flash[:fatalerror] = get_localized_text(GENERIC_NON_AUTHORIZED_MESSAGE, true)
      @users = {}
    rescue Exception => e
      log_exception_text('User search failed: ' + e.message)
      flash[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
      @users = {}
    end
  end

  def set_view_properties
    @menu = 'subscription'
    @title = get_localized_text('Subscription', true)
    @current_user_id = get_id
    @pageheader = @title
    @pageheader_image = 'subscription.png'
    set_menu_labels
    set_localization_texts
  end

  def set_localization_texts
    @localData = {}
    @localData['subscription_model'] = get_localized_text('Subscription Model', true)
    @localData['model_price'] = get_localized_text('Price', true)
    @localData['single_error_message'] = get_localized_text('Please check the field marked with *', true)
    @localData['multiple_error_message'] = get_localized_text('Please check the #n fields that has been marked with *', true)
    @localData['confirm_sub'] = get_localized_text('Confirm Subscription', true)
    @localData['requesting_subscription'] = get_localized_text('Please confirm the subscription: ', true)
    @localData['your_model'] = get_localized_text('Your Subscription Model:', true)
    @localData['model_days'] = get_localized_text('Your Subscription Days:', true)
    @localData['your_price'] = get_localized_text('Subscription Price:', true)
    @localData['confirm'] = get_localized_text('Confirm', true)
    @localData['confirm_payment'] = get_localized_text('Confirm Payment', true)
    @localData['subscription_invoice'] = get_localized_text('Subscription Invoice', true)
    @localData['subscriptioon_days'] = get_localized_text('Subscription Days', true)
    @localData['payment_status'] = get_localized_text('Payment Status', true)
    @localData['payment_date'] = get_localized_text('Payment Date', true)
    @localData['payment_transcation_id'] = get_localized_text('Transaction Identifier', true)
    @localData['select_users'] = get_localized_text('Please Select Users', true)
    @localData['total_price'] = get_localized_text('Total Price', true)
    @localData['payment_transcation_id'] = get_localized_text('Transaction Identifier', true)
  end
end
