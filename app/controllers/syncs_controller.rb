require 'nsi_services'
require 'utils'
require 'erp_sync'
require 'exceptions'

class SyncsController < BaseController
  before_filter :authenticate

  def index
    
    # TODO: Refact01

    if session[SESSION_USER_SUBSCRIPTION_REMAIN_DAYS_ERRORCODE].to_s == '8080'
      redirect_to('/subscriptions')
      return
    end
    
    set_view_properties('Synchronization')
    @syncs           = get_sync_status
    @erp_name, @mode = get_erp_name

    # apply localization
    @syncs.each do |_k, v|
      v.item              = get_localized_text(v.item, true)
      last_sync_date_time = v.last_sync.to_datetime
      v.last_sync         = get_localized_date(last_sync_date_time) + ' ' + get_localized_time(last_sync_date_time)
    end
  end

  # TODO: Look into these. Can be refactored, probably.

  def sync_timecard
    set_view_properties('Synchronization')
    sync(NSI_SERVICE_TIMECARD_SYNC, get_localized_text(TIMECARD_SYNC_SUCCESS_MESSAGE, true), get_localized_text(TIMECARD_SYNC_NOT_SUPPORTED_MESSAGE, true))
    redirect_to syncs_path
  end

  def sync_matter
    set_view_properties('Synchronization')
    sync(NSI_SERVICE_MATTER_SYNC, get_localized_text(MATTER_SYNC_SUCCESS_MESSAGE, true), get_localized_text(MATTER_SYNC_NOT_SUPPORTED_MESSAGE, true))
    redirect_to syncs_path
  end

  def sync_client
    set_view_properties('Synchronization')
    sync(NSI_SERVICE_CLIENT_SYNC, get_localized_text(CLIENT_SYNC_SUCCESS_MESSAGE, true), get_localized_text(CLIENT_SYNC_NOT_SUPPORTED_MESSAGE, true))
    redirect_to syncs_path
  end

  def sync_timekeeper
    set_view_properties('Synchronization')
    sync(NSI_SERVICE_TIMEKEEPER_SYNC, get_localized_text(TIMEKEEPER_SYNC_SUCCESS_MESSAGE, true), get_localized_text(TIMEKEEPER_SYNC_NOT_SUPPORTED_MESSAGE, true))
    redirect_to syncs_path
  end

  # TODO: Look into.

  def add_message(message, text_to_add)
    message = if message == ''
                text_to_add
              else
                message + ', ' + text_to_add
              end
    message
  end

  #   def get_success_message( message )
  #     if( message == "" )
  #       return ""
  #     else
  #       return message + " synced successfully."
  #     end
  #   end
  #
  #   def get_error_message( message )
  #     if( message == "" )
  #       return ""
  #     else
  #       return message + " sync failed."
  #     end
  #   end
  #
  #   def set_full_status_message( success_message, error_message, success )
  #     if( success )
  #         flash[:success] = get_localized_text( success_message + " " + error_message, true )
  #     else
  #         flash[:error] = get_localized_text( success_message + " "  + error_message, true )
  #     end
  #   end
  #
  #
  #   def sync_all
  #
  #     set_view_properties('Synchronization')
  #     success = false
  #     message_queue = ""
  #
  #     #sync timekeeper
  #     success = false
  #     success = sync NSI_SERVICE_TIMEKEEPER_SYNC, get_localized_text( TIMEKEEPER_SYNC_SUCCESS_MESSAGE , true ), get_localized_text( TIMEKEEPER_SYNC_NOT_SUPPORTED_MESSAGE , true )
  #     if( success )
  #       message_queue = add_message( message_queue, "Timekeeper" )
  #     else
  #       set_full_status_message( get_success_message( message_queue ), get_error_message( "Timekeeper" ), false )
  #     end
  #
  #     #sync client
  #     if( success )
  #       success = false
  #       success = sync NSI_SERVICE_CLIENT_SYNC, get_localized_text( CLIENT_SYNC_SUCCESS_MESSAGE , true ), get_localized_text( CLIENT_SYNC_NOT_SUPPORTED_MESSAGE , true )
  #       if( success )
  #         message_queue = add_message( message_queue, "Client" )
  #       else
  #         set_full_status_message( get_success_message( message_queue ), get_error_message( "Client" ), false )
  #       end
  #     end
  #
  #     #sync matter
  #     if( success )
  #       success = false
  #       success = sync NSI_SERVICE_MATTER_SYNC, get_localized_text( MATTER_SYNC_SUCCESS_MESSAGE , true ) , get_localized_text( MATTER_SYNC_NOT_SUPPORTED_MESSAGE , true )
  #       if( success )
  #         message_queue = add_message( message_queue, "Matter" )
  #       else
  #         set_full_status_message( get_success_message( message_queue ), get_error_message( "Matter" ), false )
  #       end
  #     end
  #
  #     #sync timecard
  #     if( success )
  #       success = false
  #       success = sync NSI_SERVICE_TIMECARD_SYNC, get_localized_text( TIMECARD_SYNC_SUCCESS_MESSAGE , true ) , get_localized_text( TIMECARD_SYNC_NOT_SUPPORTED_MESSAGE , true )
  #       if( success )
  #         message_queue = add_message( message_queue, "Timecard" )
  #       else
  #         set_full_status_message( get_success_message( message_queue ), get_error_message( "Timecard" ), false )
  #       end
  #     end
  #
  #     if( success )
  #       set_full_status_message( get_localized_text( SYNC_ALL_SUCCESS_MESSAGE, true ), "", true )
  #     end
  #
  #     redirect_to syncs_path
  #
  #   end

  def sync_all
    message_success = ''
    message_failed = ''
    message_not_supported = ''
    message_not_authorized = ''

    # TODO: Refactor.

    message_success, message_failed, message_not_supported, message_not_authorized = sync_with_status(NSI_SERVICE_TIMEKEEPER_SYNC, 'Timekeeper', message_success, message_failed, message_not_supported, message_not_authorized)
    message_success, message_failed, message_not_supported, message_not_authorized = sync_with_status(NSI_SERVICE_CLIENT_SYNC, 'Client', message_success, message_failed, message_not_supported, message_not_authorized)
    message_success, message_failed, message_not_supported, message_not_authorized = sync_with_status(NSI_SERVICE_MATTER_SYNC, 'Matter', message_success, message_failed, message_not_supported, message_not_authorized)
    message_success, message_failed, message_not_supported, message_not_authorized = sync_with_status(NSI_SERVICE_TIMECARD_SYNC, 'Timecard', message_success, message_failed, message_not_supported, message_not_authorized)

    # TODO: Look into.

    if message_success != ''
      flash[:success] = 'Synced succesfully: ' + message_success
    end

    flash[:error] = 'Sync failed: ' + message_failed if message_failed != ''

    if message_not_supported != ''
      flash[:notice] = 'Sync not supported for followings: ' + message_not_supported
    end

    if message_not_authorized != ''
      flash[:notice2] = "You don't have permission to sync followings: " + message_not_authorized
    end

    redirect_to syncs_path
  end

  private

  def set_view_properties(title)
    @menu             = 'sync'
    @title            = title
    @pageheader       = title
    @pageheader_image = 'synchronization.png'
    set_menu_labels
    set_localization_texts
  end

  def get_sync_status
    return ErpSync.get_sync_status get_login, get_pwd
  rescue Exceptions::ServiceNotAuthorized => exception
    log_exception_text('Failed to get sync status: ' + GENERIC_NON_AUTHORIZED_MESSAGE)
    flash.now[:fatalerror] = get_localized_text(GENERIC_NON_AUTHORIZED_MESSAGE, true)
    return nil
  rescue Exception => e
    log_exception_text('Failed to get sync status: ' + e.message)
    flash.now[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
    return nil
  end

  def sync(service, success_message, not_supported_error_message)
    success, error_code, error_message = ErpSync.sync service, get_login, get_pwd
    
    if success
      flash[:success] = success_message
      return true
    else
      if error_code == NSI_ERROR_NOT_SUPPORTED
        flash[:notice] = get_localized_text(not_supported_error_message, true)
        return false
      else
        flash[:error] = get_localized_text(error_message, true)
        return false
      end
    end
  rescue Exceptions::ServiceNotAuthorized => exception
    log_exception_text('Sync failed: ' + OPERATION_NON_AUTHORIZED_MESSAGE)
    flash[:notice] = get_localized_text(OPERATION_NON_AUTHORIZED_MESSAGE, true)
    return false
  rescue Exception => e
    log_exception_text('Sync failed: ' + e.message)
    flash[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
    return false
  end

  def sync_with_status(service, item, message_success, message_failed, message_not_supported, message_not_authorized)
    begin
      success, error_code, error_message = ErpSync.sync(service, get_login, get_pwd)
      
      # TODO: Look into.

      if success
        message_success = add_message(message_success, item)
      else
        if error_code == NSI_ERROR_NOT_SUPPORTED
          message_not_supported = add_message(message_not_supported, item)
        else
          message_failed = add_message(message_failed, item)
        end
      end
    rescue Exceptions::ServiceNotAuthorized => exception
      log_exception_text('Sync failed: ' + OPERATION_NON_AUTHORIZED_MESSAGE)
      message_not_authorized = add_message(message_not_authorized, item)
    rescue Exception => e
      log_exception_text('Sync failed: ' + e.message)
      message_failed = add_message(message_failed, item)
    end

    [message_success, message_failed, message_not_supported, message_not_authorized]
  end

  def get_erp_name
    postdata = {}
    begin
      erp_name, mode = NsiServices.get_erp_name(NsiServices.get(NSI_SERVICE_SERVICE_MODE, { 'userid' => get_login, 'password' => get_pwd }, postdata))
      return erp_name, mode
    rescue Exceptions::ServiceNotAuthorized => exception
      log_exception_text('TnB name not loaded: ' + GENERIC_NON_AUTHORIZED_MESSAGE)
      flash.now[:fatalerror] = get_localized_text(GENERIC_NON_AUTHORIZED_MESSAGE, true)
      return nil, nil
    rescue Exception => e
      log_exception_text('TnB name not loaded: ' + e.message)
      flash.now[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
      return nil, nil
    end
  end

  def set_localization_texts
    @localData = {}

    @localData['sync_timecards']            = get_localized_text('Sync Timecards', true)
    @localData['sync_timecards_with_erp']   = get_localized_text('Sync timecards with TnB', true)
    @localData['sync_clients']              = get_localized_text('Sync Clients', true)
    @localData['sync_clients_with_erp']     = get_localized_text('Sync clients with TnB', true)
    @localData['sync_matters']              = get_localized_text('Sync Matters', true)
    @localData['sync_matters_with_erp']     = get_localized_text('Sync matters with TnB', true)
    @localData['sync_timekeepers']          = get_localized_text('Sync Timekeepers', true)
    @localData['sync_timekeepers_with_erp'] = get_localized_text('Sync timekeepers with TnB', true)
    @localData['sync_all']                  = get_localized_text('Sync All', true)
    @localData['sync_all_with_erp']         = get_localized_text('Sync all with TnB', true)
    @localData['no_sync_history']           = get_localized_text('No sync history found', true)
    @localData['recent_syncs']              = get_localized_text('Recent Syncs', true)
    @localData['sync_type']                 = get_localized_text('Sync Type', true)
    @localData['sync_item']                 = get_localized_text('Sync Item', true)
    @localData['last_synced']               = get_localized_text('Last Synced', true)
    @localData['please_wait']               = get_localized_text(PLEASE_WAIT_MESSAGE, true)
    @localData['erp']                       = get_localized_text('TnB: ', true)
    @localData['mode']                      = get_localized_text('Mode: ', true)
  end
end
