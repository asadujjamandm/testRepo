require 'user_utils'
require 'exceptions'

class UsersController < BaseController
  before_filter :authenticate
  def index
    #     if (session[SESSION_USER_SUBSCRIPTION_REMAIN_DAYS_ERRORCODE].to_s == '8080')
    #       redirect_to("/subscriptions")
    #       return
    #     end

    # TOOD: Review. Refact01

    unless NsiServices.hasPermission(NSI_SERVICE_USER, 'userid' => get_login, 'password' => get_pwd) # if already signed in then return to home page
      redirect_to('/homes')
      return
    end
    @state = ''
    set_view_properties('Users')
    clear_search
    search_users
    get_roles
    set_paginate
    render 'index'
  end

  def show_user_roles

    # TODO: Rewrite.

    if !params[:user_id].nil?
      set_view_properties('Users')
      search_users
      get_roles
      get_user_roles(params[:user_id])
      filter_roles
      set_paginate
      render 'index'
    else
      process_action :index
    end
  end

  def new
    @state = ''

    # TODO: Review.

    unless NsiServices.hasPermission(NSI_SERVICE_USER, 'userid' => get_login, 'password' => get_pwd) # if already signed in then return to home page
      redirect_to('/homes')
      return
    end

    @userroles = {}
    render_new User.new
  end

  def create
    new_user   = make_user(params[:user])
    @userroles = UserUtils.make_user_roles(params[:roles], 0)
    message = new_user.validate(true)

    # TODO: Review.

    if message == ''
      status, user_id = post_user(new_user)
      if status && !user_id.nil?
        @userroles.each { |_k, v| v.user_id = user_id }
        if post_user_roles(@userroles, user_id)
          flash[:success] = USER_INSERT_SUCCESS_MESSAGE
          redirect_to action: 'new'
        else
          render_new new_user
        end
      else
        render_new new_user
      end
    else
      flash.now[:notice] = message
      render_new new_user
    end
  end

  def edit
    @state            = ''
    search_users
    @dirty_user       = get_dirty_user
    session[:dirty_u] = @dirty_user
    get_roles
    get_user_roles(@dirty_user.id)
    filter_roles
    set_paginate
    set_view_properties('Edit User')
    render 'index'
  end

  def update
    set_view_properties('')
    search_users
    updated_user = make_user(params[:user])
    @userroles = UserUtils.make_user_roles(params[:roles], updated_user.id)
    message = updated_user.validate(false)

    # TODO: Review.

    if message == ''
      if post_user(updated_user)
        if post_user_roles(@userroles, updated_user.id)
          flash[:success] = USER_UPDATE_SUCCESS_MESSAGE
          redirect_to action: 'search', page: get_current_page
        else
          render_edit updated_user
        end
      else
        render_edit updated_user
      end
    else
      flash.now[:notice] = message
      render_edit updated_user
    end
    session[:dirty_u] = nil

    auth = current_auth

    if auth.login == updated_user.email
      auth.name = updated_user.name
      sign_in(auth)
    end

  end

  def autocomplete_list
    # search_criteria = params["term"]
    search_criteria = params['term']
    extra_id        = params['extra_id']
    type            = params['type']
    userid          = params['userid']
    # dirty_id = @dirty_user.id
    uid             = get_login
    pwd             = get_pwd

    begin
        # @records = get_autocomplete uid, pwd, type, search_criteria, extra_id
        @records = get_autocomplete(uid, pwd, type, userid, search_criteria, extra_id)
      rescue Exception => e
        log_exception_text('Autocomplete dropdown list for matter, client or timekeeper loading failed: ' + e.message)
        throw 'An error occured'
      end
    render(layout: false) # layout false because its ajax
  end

  def get_autocomplete(uid, pwd, type, userid, key, extra_id)
    postdata = {}
    
    postdata['type']    = type
    postdata['userid']  = userid
    postdata['key']     = key
    postdata['extraId'] = extra_id

    begin
      return NsiServices.get_autocomplete(NsiServices.get(NSI_SERVICE_AUTOCOMPLETE, { 'userid' => uid, 'password' => pwd }, postdata))
    rescue Exceptions::ServiceNotAuthorized => exception
      log_exception_text('Autocomplete load error: ' + GENERIC_NON_AUTHORIZED_MESSAGE)
      flash.now[:fatalerror] = get_localized_text(GENERIC_NON_AUTHORIZED_MESSAGE, true)
      return {}
    rescue Exception => e
      log_exception_text('Autocomplete load error: ' + e.message)
      flash.now[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
      return {}
    end
  end

  def delete
    set_view_properties('')
    delete_user(params[:user_id])
    redirect_to action: 'search', page: get_current_page
  end

  def search
    @state         = 'search'
    @search_object = UserUtils.make_search_object(session[:user_search_object], params[:search_user])
    render_search
  end

  def external_search
    params_su        = {}
    params_su[:role] = params[:role]
    @search_object   = UserUtils.make_search_object(session[:user_search_object], params_su)
    render_search
  end

  def cancel
    redirect_to action: 'search', page: get_current_page
  end

  private

  def set_view_properties(title)
    # @menu = 'userandrole'
    @menu             = 'master'
    @title            = get_localized_text(title, true)
    @pageheader       = get_localized_text(title, true)
    @pageheader_image = 'user.png'
    @current_user_id  = get_id
    set_menu_labels
    set_localization_texts
  end

  def get_roles
    @roles = NsiServices.get_roles(NsiServices.get(NSI_SERVICE_ROLE, 'userid' => get_login, 'password' => get_pwd))
  rescue Exceptions::ServiceNotAuthorized => exception
    log_exception_text('Cannot get role list: ' + GENERIC_NON_AUTHORIZED_MESSAGE)
    flash.now[:fatalerror] = get_localized_text(GENERIC_NON_AUTHORIZED_MESSAGE, true)
    @roles = {}
  rescue Exception => e
    log_exception_text('Cannot get role list: ' + e.message)
    flash.now[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
    @roles = {}
  end

  def get_user_roles(user_id)
    @userroles = NsiServices.get_user_roles(NsiServices.get(NSI_SERVICE_USER_ROLE, { 'userid' => get_login, 'password' => get_pwd }, 'userid' => user_id))
  rescue Exceptions::ServiceNotAuthorized => exception
    log_exception_text('Cannot get user list: ' + GENERIC_NON_AUTHORIZED_MESSAGE)
    flash.now[:fatalerror] = get_localized_text(GENERIC_NON_AUTHORIZED_MESSAGE, true)
    @userroles = {}
  rescue Exception => e
    log_exception_text('Cannot get user roles: ' + e.message)
    flash.now[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
    @userroles = {}
  end

  def filter_roles

    # TODO: Review.

    unless @userroles.nil?
      @userroles.each do |_k, v|
        role             = @roles.find { |_rk, rv| rv.id == v.role_id }[1]
        v.role_name      = role.name
        v.is_role_active = role.is_active == 'yes' ? true : false
        @roles.reject! { |_rk, rv| rv.id == v.role_id }
      end
    end
  end

  def render_new(user)
    search_users
    get_roles
    filter_roles
    @dirty_user           = user
    @dirty_user.is_active = 'yes' if @dirty_user.is_active.nil?
    set_paginate
    set_view_properties('New User')
    render 'index'
  end

  def render_edit(user)
    set_view_properties('Edit User')
    get_roles
    filter_roles
    @dirty_user = user
    set_paginate
    render 'index'
  end

  def render_search
    session[:user_search_object] = @search_object
    search_users
    get_roles
    set_paginate
    render 'index'
  end

  def make_user(params_users)
    updated_user_id = params_users.nil? ? nil : params_users[:updated_user_id]

    # TODO: Rewrite this.

    if !updated_user_id.nil?
      updated_user = if !session[:dirty_u].nil?
                       session[:dirty_u]
                     else
                       User.new
                     end
      updated_user.id = updated_user_id
      UserUtils.make_user(params_users, updated_user)

    else
      return nil
    end
  end

  # TODO: There's a lot of the same logic in these next few methods.

  def post_user(u)
    postdata = {}
    UserUtils.make_user_post_data(postdata, u) unless u.nil?
    resp = NsiServices.post(NSI_SERVICE_USER, { 'userid' => get_login, 'password' => get_pwd }, postdata)
    if NsiServices.is_resp_success(resp)
      return true, NsiServices.get_resp_return_data(resp)
    else
      log('Cannot update user: ' + NsiServices.resp_message(resp))
      flash[:error] = get_localized_text(NsiServices.resp_message(resp), true)
      return false, nil
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

  def post_user_roles(user_roles, user_id)
    postdata = {}
    UserUtils.make_user_role_post_data postdata, user_roles, user_id
    resp = NsiServices.post(NSI_SERVICE_USER_ROLE, { 'userid' => get_login, 'password' => get_pwd }, postdata)
    if NsiServices.is_resp_success(resp)
      return true
    else
      log('Unable to update user roles: ' + NsiServices.resp_message(resp))
      flash[:error] = get_localized_text(NsiServices.resp_message(resp), true)
      return false
    end
  rescue Exceptions::OperationNotAuthorized => exception
    log_exception_text('Unable to update user roles: ' + OPERATION_NON_AUTHORIZED_MESSAGE)
    flash[:fatalerror] = get_localized_text(OPERATION_NON_AUTHORIZED_MESSAGE, true)
    return false, nil
  rescue Exception => e
    log_exception_text('Unable to update user roles: ' + e.message)
    flash[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
    return false, nil
  end

  def delete_user(user_id)
    if user_id.nil? || user_id.empty?
      flash[:error] = USER_INVALID_MESSAGE
    else
      resp = NsiServices.delete(NSI_SERVICE_USER, { 'userid' => get_login, 'password' => get_pwd }, 'id' => user_id)
      if NsiServices.is_resp_success(resp)
        flash[:success] = get_localized_text(USER_DELETE_SUCCESS_MESSAGE, true)
      else
        log('Unable to delete user: ' + NsiServices.resp_message(resp))
        flash[:error] = get_localized_text(NsiServices.resp_message(resp), true)
      end
    end
  rescue Exceptions::OperationNotAuthorized => exception
    log_exception_text('Unable to delete user: ' + OPERATION_NON_AUTHORIZED_MESSAGE)
    flash[:fatalerror] = get_localized_text(OPERATION_NON_AUTHORIZED_MESSAGE, true)
  rescue Exception => e
    log_exception_text('Unable to delete user: ' + e.message)
    flash[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
  end

  def search_users
    @search_object = session[:user_search_object]

    # TOOD: Review.

    begin
      if !@search_object.nil?
        @users = NsiServices.get_users(NsiServices.get(NSI_SERVICE_USER, { 'userid' => get_login, 'password' => get_pwd, 'usereditlist' => 'usereditlist' }, 'roleid' => @search_object.role_id, 'isactive' => @search_object.is_active))
      else
        @users = NsiServices.get_users(NsiServices.get(NSI_SERVICE_USER, { 'userid' => get_login, 'password' => get_pwd }, 'usereditlist' => '10'))
        puts @users
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
   
    header = ''

    unless @search_object.nil?
      header += 'Search Users by Role' if @search_object.role_id != ''
      if @search_object.is_active != ''
        if header != ''
          header += ', '
          header += 'Status'
        else
          header += 'Search Users by Status'
        end
      end
    end
    set_view_properties(header == '' ? 'Users' : header)
  end

  def clear_search
    session.delete :user_search_object
  end

  def set_paginate
    @current_page = get_current_page

    if @users.count > 0
      @page_results = WillPaginate::Collection.create(@current_page, get_user_page_size, @users.count) do |pager|
        @start = (@current_page - 1) * get_user_page_size
        pager.replace @users.to_a[@start, get_user_page_size]
      end
    end
  end

  def get_dirty_user
    dirty_user_id = params[:user_id]
    @users.find { |_k, v| v.id == dirty_user_id }[1] unless dirty_user_id.nil?
  end

  def get_current_page
    params[:page].nil? ? 1 : Integer(params[:page])
  end

  def set_localization_texts
    @localData = {}

    @localData['save']                                        = get_localized_text('Save', true)
    @localData['save_new_user']                               = get_localized_text('Save new user', true)
    @localData['show_users']                                  = get_localized_text('Show Users', true)
    @localData['update']                                      = get_localized_text('Update', true)
    @localData['update_changed_user']                         = get_localized_text('Update changed user', true)
    @localData['cancel_changes']                              = get_localized_text('Cancel Changes', true)
    @localData['add_new']                                     = get_localized_text('Add New', true)
    @localData['create_new_user']                             = get_localized_text('Create new user', true)
    @localData['show_users']                                  = get_localized_text('Show Users', true)
    @localData['search']                                      = get_localized_text('Search', true)
    @localData['search_users']                                = get_localized_text('Search users', true)
    @localData['name']                                        = get_localized_text('Name', true)
    @localData['email']                                       = get_localized_text('E-mail', true)
    @localData['login']                                       = get_localized_text('Login', true)
    @localData['password']                                    = get_localized_text('Password', true)
    @localData['confirm_password']                            = get_localized_text('Confirm password', true)
    @localData['is_active']                                   = get_localized_text('Is Active', true)
    @localData['status']                                      = get_localized_text('Status', true)
    @localData['view_roles']                                  = get_localized_text('View roles', true)
    @localData['edit']                                        = get_localized_text('Edit', true)
    @localData['edit_user']                                   = get_localized_text('Edit user', true)
    @localData['delete']                                      = get_localized_text('Delete', true)
    @localData['delete_user']                                 = get_localized_text('Delete user', true)
    @localData['user_is_not_deletable']                       = get_localized_text('User is not deletable', true)
    @localData['role_view_is_not_enabled']                    = get_localized_text('Role view is not enabled', true)
    @localData['user_is_not_editable']                        = get_localized_text('User is not editable', true)
    @localData['user_is_not_deletable']                       = get_localized_text('User is not deletable', true)
    @localData['records']                                     = get_localized_text('Records ', true)
    @localData['to']                                          = get_localized_text(' to ', true)
    @localData['of']                                          = get_localized_text(' , total records ', true)
    @localData['assign_user_to_role']                         = get_localized_text('Assign user to role', true)
    @localData['remove_user_from_role']                       = get_localized_text('Remove user from role', true)
    @localData['role']                                        = get_localized_text('Role', true)
    @localData['is_role_admin']                               = get_localized_text('Is Role Admin', true)
    @localData['can_read_all']                                = get_localized_text('Can Read All', true)
    @localData['assigned_roles_of_user']                      = get_localized_text('Assigned roles of user: ', true)
    @localData['assign_roles']                                = get_localized_text('Assign Roles', true)
    @localData['user_status']                                 = get_localized_text('User status', true)
    @localData['new_user']                                    = get_localized_text('New User', true)
    @localData['at_least_one_role_must_be_added']             = get_localized_text('At least one role must be added', true)
    @localData['are_you_sure_you_want_to_update_this_record'] = get_localized_text('Are you sure you want to update this user?', true)
    @localData['are_you_sure_you_want_to_delete_the_user']    = get_localized_text('Are you sure, you want to delete this user?', true)
    @localData['are_you_sure_you_want_to_cancel_the_user']    = get_localized_text('Are you sure, you want to cancel?', true)
    @localData['single_error_message']                        = get_localized_text('Please check the field marked with *', true)
    @localData['multiple_error_message']                      = get_localized_text('Please check the #n fields that has been marked with *', true)
    @localData['timekeeper']                                  = get_localized_text('Timekeeper', true)
  end
end
