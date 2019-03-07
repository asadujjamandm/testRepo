require 'exceptions'

class RolesController < BaseController
  before_filter :authenticate

  def index
    if (!NsiServices.hasPermission(NSI_SERVICE_ROLE, {'userid' => get_login, 'password' => get_pwd})) #if already signed in then return to home page
      redirect_to("/homes")
      return
    end
    @updateORNew = "create"
    set_view_properties('Roles')
    get_roles
    set_paginate
    render 'index'
  end

  def show_role_permissions
    get_role_permissions params[:role_id] unless params[:role_id].nil?

    process_action :index
  end

  def new
    @updateORNew = "create"
    get_role_permissions(nil)
    render_new Role.new
  end

  def create
    @updateORNew     = "create"
    new_role         = make_role params[:role]
    @rolepermissions = make_role_permissions(params[:permission])
    message          = new_role.validate

    if message == ''
      status, role_id = post_role(new_role)

      if status && !role_id.nil?
        
        if post_role_permissions(@rolepermissions, role_id)
          flash[:success] = get_localized_text(ROLE_INSERT_SUCCESS_MESSAGE , true)
          redirect_to :action => 'new'
        else
          render_new new_role
        end
      else
        render_new new_role
      end
    else
      flash.now[:notice] = message
      render_new new_role
    end
  end

  def edit
    set_view_properties('Edit Role')
    @updateORNew      = "update"
    get_roles
    @dirty_role       = get_dirty_role
    get_role_permissions @dirty_role.id
    session[:dirty_r] = @dirty_role
    set_paginate
    render 'index'
  end

  def update
    set_view_properties('')
    @updateORNew      = "create"
    get_roles
    @rolepermissions  = make_role_permissions(params[:permission])
    updated_role      = make_role params[:role]
    message           = updated_role.validate
 
    if message == ''
      if post_role(updated_role)
        if post_role_permissions(@rolepermissions, updated_role.id)
          flash[:success] = get_localized_text(ROLE_UPDATE_SUCCESS_MESSAGE, true)
          redirect_to :action => 'index', :page => get_current_page
        else
          render_edit updated_role
        end
      else
        render_edit updated_role
      end
    else
      flash.now[:notice] = message
      render_edit updated_role
    end
    session[:dirty_r] = nil
  end

  def delete
    set_view_properties('')
    delete_role(params[:role_id])
    redirect_to :action => 'index', :page => get_current_page
  end

  def cancel
    redirect_to :action => 'index', :page => get_current_page
  end

  private

  def set_view_properties(title)
    #@menu = 'userandrole'
    @menu             = 'master'
    @title            = get_localized_text(title, true)
    @pageheader       = get_localized_text(title, true)
    @pageheader_image = 'role.png'
    set_menu_labels
    set_localization_texts
  end

  def get_roles
    begin
      @roles = NsiServices.get_roles(NsiServices.get(NSI_SERVICE_ROLE, {'userid' => get_login, 'password' => get_pwd}))
      #apply localization
      @roles.each do |k, v|
        v.desc = get_localized_text(v.desc, true)
      end
    rescue Exceptions::ServiceNotAuthorized => exception
      log_exception_text("Error while getting role list: " + GENERIC_NON_AUTHORIZED_MESSAGE)
      flash.now[:fatalerror] = get_localized_text(GENERIC_NON_AUTHORIZED_MESSAGE, true)
      @roles = {}
    rescue Exception => e
      log_exception_text("Error while getting role list: " + e.message)
      flash.now[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
      @roles = {}
    end
  end

  def render_new(role)
    set_view_properties('New Role')
    get_roles
    @dirty_role = role

    # TODO: This code seems to be repeated a lot. Prob refactor.

    @dirty_role.is_active = 'yes' if @dirty_role.is_active.nil?

    set_paginate
    render 'index'
  end

  def render_edit(role)
    set_view_properties('Edit Role')
    @dirty_role = role
    set_paginate
    render 'index'
  end

  def make_role(params_roles)
    updated_role_id = params_roles.nil? ? nil : params_roles[:updated_role_id]

    # TODO: Rewrite this.

    if !updated_role_id.nil?
      if !session[:dirty_r].nil?
        updated_role = session[:dirty_r]
      else
        updated_role = Role.new
      end
      updated_role.id = updated_role_id
      updated_role.name = params_roles[:name].nil? ? updated_role.name : params_roles[:name]
      updated_role.desc = params_roles[:desc].nil? ? updated_role.login : params_roles[:desc]
      updated_role.is_active = params_roles[:is_active].nil? ? updated_role.is_active : params_roles[:is_active]
      return updated_role
    else
      return nil
    end
  end

  def make_role_permissions(param_permissions)
    return nil if param_permissions.nil?
    role_permissions = {}
    param_permissions.each do |i, rp|
      role_permission = RolePermission.new
      role_permission.service_object_id = rp['service_object_id']
      role_permission.operation = rp['operation']
      role_permission.permission = rp['permission']
      role_permission.description = rp['description']
      role_permissions.merge!({i => role_permission})
    end
    return role_permissions
  end

  def make_post_data(postdata, r)
    postdata.merge!({"id" => r.id})
    postdata.merge!({"role" => r.name})
    postdata.merge!({"desc" => get_localized_text(r.desc, false)})
    postdata.merge!({"isactive" => r.is_active})
  end

  def make_role_permission_post_data(postdata, rp, role_id)
    index = 0
    postdata.merge!({"roleid" => role_id})

    # TODO: Rewrite

    if !rp.nil?
      rp.each do |k, v|
        postdata.merge!({"serviceobjectid#{index}" => v.service_object_id})
        postdata.merge!({"operation#{index}" => v.operation})
        postdata.merge!({"permission#{index}" => v.permission})
        index += 1
      end
    end
  end

  def post_role(r) # r = role? unsure
    begin
      postdata = {}
      
      make_post_data(postdata, r) unless r.nil?
      
      resp = NsiServices.post(NSI_SERVICE_ROLE, {'userid' => get_login, 'password' => get_pwd}, postdata)
      
      if NsiServices.is_resp_success(resp)
        return true, NsiServices.get_resp_return_data(resp)
      else
        log('Role update failed: ' + NsiServices.resp_message(resp))
        flash[:error] = NsiServices.resp_message(resp)
        return false, nil
      end
    rescue Exceptions::OperationNotAuthorized => exception
      log_exception_text("Role update failed: " + OPERATION_NON_AUTHORIZED_MESSAGE)
      flash[:fatalerror] = get_localized_text(OPERATION_NON_AUTHORIZED_MESSAGE, true)
      return false, nil
    rescue Exception => e
      log_exception_text("Role update failed: " + e.message)
      flash[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
      return false, nil
    end
  end

  def post_role_permissions(roles_permissions, role_id)
    begin
      postdata = {}
      make_role_permission_post_data(postdata, roles_permissions, role_id)
      resp = NsiServices.post(NSI_SERVICE_ROLE_PERMISSION, {'userid' => get_login, 'password' => get_pwd}, postdata)

      if NsiServices.is_resp_success(resp)
        return true
      else
        log( 'Role permission update failed: ' + NsiServices.resp_message(resp) )
        flash[:error] = NsiServices.resp_message(resp)
        return false
      end
    rescue Exceptions::OperationNotAuthorized => exception
      log_exception_text ( "Role permission update failed: " + OPERATION_NON_AUTHORIZED_MESSAGE )
      flash[:fatalerror] = get_localized_text( OPERATION_NON_AUTHORIZED_MESSAGE , true )
      return false, nil
    rescue Exception => e
      log_exception_text ( "Role permission update failed: " + e.message )
      flash[:fatalerror] = get_localized_text( GENERIC_FATAL_ERROR_MESSAGE , true )
      return false, nil
    end
  end

  def delete_role(role_id)
    begin
      if role_id.nil? || role_id.empty?
        flash[:error] = get_localized_text(ROLE_INVALID_MESSAGE, true)
      else
        resp = NsiServices.delete(NSI_SERVICE_ROLE, {'userid' => get_login, 'password' => get_pwd}, {'id' => role_id})
        if NsiServices.is_resp_success(resp)
          flash[:success] = get_localized_text(ROLE_DELETE_SUCCESS_MESSAGE, true)
        else
          log('Role deletion failed: ' + NsiServices.resp_message(resp))
          flash[:error] = NsiServices.resp_message(resp)
        end
      end
    rescue Exceptions::OperationNotAuthorized => exception
      log_exception_text("Role deletion failed: " + OPERATION_NON_AUTHORIZED_MESSAGE)
      flash[:fatalerror] = get_localized_text(OPERATION_NON_AUTHORIZED_MESSAGE, true)
    rescue Exception => e
      log_exception_text("Role deletion failed: " + e.message)
      flash[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
    end
  end

  def get_role_permissions(role_id)
    begin

      # TODO: Rewrite

      if role_id.nil?
        @rolepermissions = NsiServices.get_role_permissions(NsiServices.get(NSI_SERVICE_ROLE_PERMISSION, {'userid' => get_login, 'password' => get_pwd}))
      else
        @rolepermissions = NsiServices.get_role_permissions(NsiServices.get(NSI_SERVICE_ROLE_PERMISSION, {'userid' => get_login, 'password' => get_pwd}, {'roleid' => role_id}))
      end
      #localize

      @rolepermissions.each do |k, v|
        v.description = get_localized_text(v.description, true)
      end
    rescue Exceptions::ServiceNotAuthorized => exception
      log_exception_text("Error while loading role permission: " + GENERIC_NON_AUTHORIZED_MESSAGE)
      flash.now[:fatalerror] = get_localized_text(GENERIC_NON_AUTHORIZED_MESSAGE, true)
      @rolepermissions = {}
    rescue Exception => e
      log_exception_text("Error while loading role permission: " + e.message)
      flash.now[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
      @rolepermissions = {}
    end
  end

  def set_paginate
    @current_page = get_current_page

    if @roles.count > 0
      @page_results = WillPaginate::Collection.create(@current_page, get_role_page_size, @roles.count) do |pager|
        @start = (@current_page - 1) * get_role_page_size
        pager.replace @roles.to_a[@start, get_role_page_size]
      end
    end
  end

  def get_dirty_role
    dirty_role_id = params[:role_id]
    
    # TODO: Rewrite

    if !dirty_role_id.nil?
      @roles.find { |k, v| v.id == dirty_role_id }[1]
    else
      nil
    end
  end

  def get_current_page
    params[:page].nil? ? 1 : Integer(params[:page])
  end

  def set_localization_texts()

    @localData = {}

    @localData['save']                                        = get_localized_text('Save', true)
    @localData['save_new_role']                               = get_localized_text('Save new role', true)
    @localData['show_roles']                                  = get_localized_text('Show Roles', true)
    @localData['update']                                      = get_localized_text('Update', true)
    @localData['update_changed_role']                         = get_localized_text('Update changed role', true)
    @localData['cancel_changes']                              = get_localized_text('Cancel Changes', true)
    @localData['add_new']                                     = get_localized_text('Add New', true)
    @localData['create_new_role']                             = get_localized_text('Create new role', true)
    @localData['select_all']                                  = get_localized_text('Select All', true)
    @localData['select_default']                              = get_localized_text('Select Default', true)
    @localData['select_none']                                 = get_localized_text('Select None', true)
    @localData['name']                                        = get_localized_text('Name', true)
    @localData['is_active']                                   = get_localized_text('Is Active', true)
    @localData['description']                                 = get_localized_text('Description', true)
    @localData['actions']                                     = get_localized_text('Actions', true)
    @localData['status']                                      = get_localized_text('Status', true)
    @localData['view_users']                                  = get_localized_text('View users', true)
    @localData['view_permissions']                            = get_localized_text('View permissions', true)
    @localData['edit']                                        = get_localized_text('Edit', true)
    @localData['edit_role']                                   = get_localized_text('Edit role', true)
    @localData['delete']                                      = get_localized_text('Delete', true)
    @localData['delete_role']                                 = get_localized_text('Delete role', true)
    @localData['user_view_is_not_enabled']                    = get_localized_text('User view is not enabled', true)
    @localData['permission_view_is_not_enabled']              = get_localized_text('Permission view is not enabled', true)
    @localData['role_is_not_editable']                        = get_localized_text('Role is not editable', true)
    @localData['role_is_not_deletable']                       = get_localized_text('Role is not deletable', true)
    @localData['records']                                     = get_localized_text('Records ', true)
    @localData['to']                                          = get_localized_text(' to ', true)
    @localData['of']                                          = get_localized_text(' , total records ', true)
    @localData['assigned_permissions_of_role']                = get_localized_text('Assigned permissions of role: ', true)
    @localData['assign_permissons']                           = get_localized_text('Assign Permissons', true)
    @localData['new_role']                                    = get_localized_text('New Role', true)
    @localData['are_you_sure_you_want_to_update_this_record'] = get_localized_text('Are you sure, you want to update this role?', true)
    @localData['are_you_sure_you_want_to_delete_this_role']   = get_localized_text('Are you sure, you want to delete this role?', true)
    @localData['are_you_sure_you_want_to_cancel_this_role']   = get_localized_text('Are you sure, you want to cancel?', true)
    @localData['single_error_message']                        = get_localized_text('Please check the field marked with *', true)
    @localData['multiple_error_message']                      = get_localized_text('Please check the #n fields that has been marked with *', true)

  end

end