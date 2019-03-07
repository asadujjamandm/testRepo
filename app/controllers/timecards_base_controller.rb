require 'exceptions'

class TimecardsBaseController < BaseController

  def get_matter(uid, pwd, matter_id)
    begin
      @matters = NsiServices.get_matters NsiServices.get(NSI_SERVICE_MATTER, {'userid' => uid, 'password' => pwd, 'matterid' => matter_id})
    rescue Exceptions::ServiceNotAuthorized => exception
      log_exception_text("Matter load error: " + GENERIC_NON_AUTHORIZED_MESSAGE)
      flash.now[:fatalerror] = get_localized_text(GENERIC_NON_AUTHORIZED_MESSAGE, true)
      return {}
    rescue Exception=> e
      log_exception_text("Matter load error: " + e.message)
      flash.now[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
      return {}
    end
  end

  def get_matter_by_number(uid, pwd, matter_number)
    begin
      @matters = NsiServices.get_matters NsiServices.get(NSI_SERVICE_MATTER, {'userid' => uid, 'password' => pwd, 'matterNumber' => matter_number})
    rescue Exceptions::ServiceNotAuthorized => exception
      log_exception_text("Matter load error: " + GENERIC_NON_AUTHORIZED_MESSAGE)
      flash.now[:fatalerror] = get_localized_text(GENERIC_NON_AUTHORIZED_MESSAGE, true)
      return {}
    rescue Exception=> e
      log_exception_text("Matter load error: " + e.message)
      flash.now[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
      return {}
    end
  end

  def get_autocomplete(uid, pwd, type, key, extra_id)
    postdata = {}
    postdata.merge!({"type" => type})
    postdata.merge!({"key" => key})
    postdata.merge!({"extraId" => extra_id})

    begin
      return NsiServices.get_autocomplete( NsiServices.get(NSI_SERVICE_AUTOCOMPLETE, {'userid' => uid, 'password' => pwd}, postdata) )
    rescue Exceptions::ServiceNotAuthorized => exception
      log_exception_text("Autocomplete load error: " + GENERIC_NON_AUTHORIZED_MESSAGE)
      flash.now[:fatalerror] = get_localized_text(GENERIC_NON_AUTHORIZED_MESSAGE, true)
      return {}
    rescue Exception=> e
      log_exception_text("Autocomplete load error: " + e.message)
      flash.now[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
      return {}
    end
  end

  def post_timecards
    begin
      postdata        = {}
      timecards_count = 0

      @updated_timecards.each do |k, v|
        if v.is_dirty_confirmed?
          #apply localization(reverse)
          v.template    = get_localized_text(v.template, false)
          v.description = get_localized_text(v.description, false)
          v.date        = get_date_as_string(v.date)
          v.hhmm        = get_time_as_string(v.hhmm)

          make_post_data(postdata, v, timecards_count)
          timecards_count += 1
        end
      end

      resp = NsiServices.post(NSI_SERVICE_TIMECARD_COLLECTION, {'userid' => get_login, 'password' => get_pwd}, postdata)
      
      if NsiServices.is_resp_success(resp)
        flash[:success] = get_localized_text(TIMECARD_UPDATE_SUCCESS_MESSAGE, true)
      else
        message = NsiServices.resp_message(resp)
        log('Timecard update failed: ' + message)
        flash[:error] = message
      end
    rescue Exceptions::OperationNotAuthorized => exception
      log_exception_text("Timecard update failed: " + OPERATION_NON_AUTHORIZED_MESSAGE)
      flash[:fatalerror] = get_localized_text(OPERATION_NON_AUTHORIZED_MESSAGE, true)
    rescue Exception => e
      log_exception_text ('Timecard update failed: ' + e.message)
      flash[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
    end
  end

  def make_post_data(postdata, t, index)
    postdata.merge!({"id#{index}" => t.id})
    postdata.merge!({"matter#{index}" => t.matter_id})

    unless t.matter_id.index("temp_mttr_").nil?
         length          = t.matter_id.length
         matching_length = "temp_mttr_".length
         t.matter_number = t.matter_id[matching_length, (length - matching_length)]
    end
    postdata.merge!({"template#{index}"         => t.template})
    postdata.merge!({"desc#{index}"             => t.description})
    postdata.merge!({"client#{index}"           => t.client_id})
    postdata.merge!({"timekeeper#{index}"       => t.timekeeper_id})
    postdata.merge!({"hours#{index}"            => t.hours})
    postdata.merge!({"units#{index}"            => t.units})
    postdata.merge!({"hhmm#{index}"             => t.hhmm})
    postdata.merge!({"date#{index}"             => t.date})
    postdata.merge!({"billStatus#{index}"       => t.bill_status})
    postdata.merge!({"message#{index}"          => t.message})
    postdata.merge!({"approved#{index}"         => t.approved})
    postdata.merge!({"activitycode#{index}"     => t.activity_id})
    postdata.merge!({"ledger#{index}"           => t.ledger_id})
    postdata.merge!({"tax#{index}"              => t.tax_id})
    postdata.merge!({"task#{index}"             => t.task_id})
    postdata.merge!({"dept#{index}"             => t.depaprtment_id})
    postdata.merge!({"location#{index}"         => t.location_id})
    postdata.merge!({"posted#{index}"           => t.posted})
    postdata.merge!({"matternumber#{index}"     => t.matter_number})
    postdata.merge!({"clientname#{index}"       => t.client_number})
    postdata.merge!({"timekeepernumber#{index}" => t.timekeeper_number})
    postdata.merge!({"userid#{index}"           => t.user_id})
    postdata.merge!({"internalcomment#{index}"  => t.internal_comment})
  end

  def post_timecard(t, finalized)
    begin
      postdata = {}
      unless t.nil?
        #t.activity_id = TIMECARD_DEFUALT_REFERENCE_VALUE
        t.ledger_id      = TIMECARD_DEFUALT_REFERENCE_VALUE
        t.tax_id         = TIMECARD_DEFUALT_REFERENCE_VALUE
        t.task_id        = TIMECARD_DEFUALT_REFERENCE_VALUE
        t.depaprtment_id = TIMECARD_DEFUALT_REFERENCE_VALUE
        t.location_id    = TIMECARD_DEFUALT_REFERENCE_VALUE

        #apply localization(reverse)
        t.template         = get_localized_text(t.template, false)
        t.description      = get_localized_text(t.description, false)
        t.internal_comment = get_localized_text(t.internal_comment, false)
        t.date             = get_date_as_string(t.date)
        t.hhmm             = get_time_as_string(t.hhmm)

        make_post_data(postdata, t, '')
      end

      temp_tc                   = t
      temp_tc.matter_number     = @_params[:timecard][:matter_number]
      temp_tc.client_number     = @_params[:timecard][:client_number]
      temp_tc.timekeeper_number = @_params[:timecard][:timekeeper_number]
      temp_tc.is_cached         = true
      temp_tc.activity_code     = @_params[:timecard][:activity_code]
      session[:cached_timecard] = t

      false_or_true = finalized == 'true' ? 'true' : 'false'

      resp = NsiServices.post(NSI_SERVICE_TIMECARD, {'userid' => get_login, 'password' => get_pwd, "finalized" => false_or_true}, postdata)

      if NsiServices.is_resp_success(resp)
        flash[:success] = finalized == 'true' ? get_localized_text(TIMECARD_POST_SUCCESS_MESSAGE, true) : get_localized_text(TIMECARD_INSERT_SUCCESS_MESSAGE, true)
        return true
      else
        message = NsiServices.resp_message(resp)
        log('Timecard insert failed: ' + message)
        flash[:error] = message
        return false
      end
    rescue Exceptions::OperationNotAuthorized => exception
      log_exception_text("Timecard insert failed: " + OPERATION_NON_AUTHORIZED_MESSAGE)
      flash[:fatalerror] = get_localized_text(OPERATION_NON_AUTHORIZED_MESSAGE, true)
      return false
    rescue Exception => e
      log_exception_text("Timecard insert failed: " + e.message)
      flash[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
      return false
    end
  end

  def search_timecards
    @search_object = session[:search_object]

    return if @search_object.nil?

    # TODO: Refactor this. All of this.
    
    @search_object.from_date = @search_object.to_date if (@search_object.from_date.nil? || @search_object.from_date == '') && !(@search_object.to_date.nil? || @search_object.to_date == '')
    
    @search_object.to_date = @search_object.from_date if (@search_object.to_date.nil? || @search_object.to_date == '') && !(@search_object.from_date.nil? || @search_object.from_date == '')


    if !(@search_object.to_date.nil? || @search_object.to_date == '') && !(@search_object.from_date.nil? || @search_object.from_date == '')
      begin
        date1 = Date.strptime(get_date_as_string(@search_object.from_date))
        date2 = Date.strptime(get_date_as_string(@search_object.to_date))
      rescue Exception=>e
        log_exception_text("Invalid timecard search date: " + e.message)
        date1 = get_localized_date(Date.today)
        date2 = get_localized_date(Date.today)
        @search_object.from_date = date1
        @search_object.to_date = date2
      end

      if date1 > date2
        tmp =  @search_object.from_date
        @search_object.from_date = @search_object.to_date
        @search_object.to_date   = tmp
      end
    end

    # Apply localization
    
    @search_object.from_date = get_date_as_string(@search_object.from_date) unless @search_object.from_date.nil? || @search_object.from_date == ''
    @search_object.to_date   = get_date_as_string(@search_object.to_date) unless @search_object.to_date.nil? || @search_object.to_date == ''
    

    query, filtered_by    = TimecardUtils.get_search_query(@search_object, method(:get_localized_date), method(:get_localized_text))
    page_parameter        = params['page']

    page_parameter        = '1' if page_parameter.nil? || page_parameter == ''
    query['current_page'] = page_parameter
    query['page_size']    = get_timecard_page_size

      #undo localization
    
    @search_object.from_date = get_localized_date(@search_object.from_date.to_date()) unless @search_object.from_date.nil? || @search_object.from_date == ''
    @search_object.to_date   = get_localized_date(@search_object.to_date.to_date()) unless @search_object.to_date.nil? || @search_object.to_date == ''

    set_view_properties(@pageheader + (filtered_by.size > 0 ? ('' + filtered_by) : ''))
    unless query.nil?
      p "Query: " + query.to_s

      begin
        @timecards, @current_page, @total_records, @page_size = NsiServices.get_paged_timecards(NsiServices.get(NSI_SERVICE_TIMECARD_REPORT, {'userid' => get_login, 'password' => get_pwd}, query))
        #fill_ref_objects
        #apply localization
        @timecards.each do |k, v|
          v.template         = get_localized_text(v.template, true)
          v.description      = get_localized_text(v.description, true)
          v.internal_comment = get_localized_text(v.internal_comment, true)
          v.date             = get_localized_date(v.date.to_date())
          v.hhmm             = get_localized_time(('2000-01-01 ' + v.hhmm).to_datetime())
        end
        #session[:timecards] = @timecards
      rescue Exceptions::ServiceNotAuthorized => exception
        log_exception_text("Unable to load timecard list: " + GENERIC_NON_AUTHORIZED_MESSAGE)
        flash[:fatalerror] = get_localized_text( GENERIC_NON_AUTHORIZED_MESSAGE, true)
      rescue Exception=>e
        log_exception_text("Unable to load timecard list: " + e.message)
        flash[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
      end
    end
  end

  def delete_timecard(timecard_id)
    begin
      if timecard_id.nil? || timecard_id.empty?
        flash[:error] = get_localized_text(TIMECARD_INVALID_MESSAGE, true)
      else
        resp = NsiServices.delete(NSI_SERVICE_TIMECARD, {'userid' => get_login, 'password' => get_pwd}, {'timecard_id' => timecard_id})
        
        if NsiServices.is_resp_success(resp)
          flash[:success] = get_localized_text(TIMECARD_DELETE_SUCCESS_MESSAGE, true)
        else
          log("Unable to delete timecard: " + NsiServices.resp_message(resp))
          flash[:error] = NsiServices.resp_message(resp)
        end
      end
    rescue Exceptions::OperationNotAuthorized => exception
      log_exception_text("Unable to delete timecard: " + OPERATION_NON_AUTHORIZED_MESSAGE)
      flash[:fatalerror] = get_localized_text(OPERATION_NON_AUTHORIZED_MESSAGE, true)
    rescue Exception => e
      log_exception_text("Unable to delete timecard: " + e.message)
      flash[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
    end
  end

  def make_temp_matter_post_data(postdata, input)

    user_id = session[:remember_token][3]

    postdata.merge!({"clientID0"             => input["timecard"][ "client_id2" ]})
    postdata.merge!({"matterNumber0"         => input["matter_number2"]})
    postdata.merge!({"matterName0"           => input["matter_name2"]})
    postdata.merge!({"matterNickName0"       => input["matter_nick2"]})
    postdata.merge!({"matterDescription0"    => input["matter_description2"]})
    postdata.merge!({"narrative0"            => ''})
    postdata.merge!({"isTempMatter0"         => "yes"})
    postdata.merge!({"isActive0"             => "yes"})
    postdata.merge!({"userID0"               => user_id})
    postdata.merge!({"openDate0"             => ""})
    postdata.merge!({"closeDate0"            => ""})
    postdata.merge!({"isNonBillable0"        => ""})
    postdata.merge!({"isNoCharge0"           => ""})
    postdata.merge!({"isAdmin0"              => ""})
    postdata.merge!({"isProBono0"            => ""})
    postdata.merge!({"isMaster0"             => ""})
    postdata.merge!({"defaultTimeIncrement0" => ""})
    postdata.merge!({"defaultMarkup0"        => ""})
    postdata.merge!({"relatedMatterID0"      => ""})
    postdata.merge!({"parentMatterID0"       => ""})
    postdata.merge!({"clientContactID0"      => ""})
    postdata.merge!({"defaultTimekeeperID0"  => ""})
    postdata.merge!({"supervisingTkprID0"    => ""})
    postdata.merge!({"matterRateID0"         => ""})
    postdata.merge!({"matterLanguageID0"     => ""})
    postdata.merge!({"matterTypeID0"         => ""})
    postdata.merge!({"timeTaxID0"            => ""})
    postdata.merge!({"costTaxID0"            => ""})
    postdata.merge!({"chargeTaxID0"          => ""})
    postdata.merge!({"unit0"                 => ""})
    postdata.merge!({"mT_UDF00"              => ""})
    postdata.merge!({"mT_UDF10"              => ""})
    postdata.merge!({"mT_UDF20"              => ""})
    postdata.merge!({"mT_UDF30"              => ""})
    postdata.merge!({"mT_UDF40"              => ""})
    postdata.merge!({"mT_UDF50"              => ""})
    postdata.merge!({"mT_UDF60"              => ""})
    postdata.merge!({"mT_UDF70"              => ""})
    postdata.merge!({"mT_UDF80"              => ""})
    postdata.merge!({"mT_UDF90"              => ""})
    postdata.merge!({"matterCurrencyID0"     => ""})
    postdata.merge!({"isPosted0"             => ""})
    postdata.merge!({"matterID0"             => ""})
    postdata.merge!({"createddate0"          => ""})
    postdata.merge!({"modifieddate0"         => ""})
  end

  def post_temp_matter
    begin
      postdata = {}
      make_temp_matter_post_data(postdata, params)

      resp = NsiServices.post(NSI_SERVICE_MATTER, {'userid' => get_login, 'password' => get_pwd}, postdata)
      if NsiServices.is_resp_success(resp)
        matter_number = '' +  params["matter_number2"]
        #as its a success, set matter's session to null(to reload again)
        #session[:matters] = nil
        uid = get_login
        pwd = get_pwd
        
        begin
          get_matter_by_number(uid, pwd, matter_number)
          m     = @matters.find { |mk, mv| mv.matter_number == matter_number }
          @data = (m.nil? || m.count < 2 ) ? "##error**" : ( m[1].id + "*#+" + m[1].matter_number )
        rescue Exception => e
          log_exception_text("Temp matter not found: " + e.message)
          @data = "##error**"
        end
      else
        @data = "##error**" + get_localized_text(NsiServices.resp_message(resp), true)
      end

    rescue Exceptions::OperationNotAuthorized => exception
      log_exception_text("Unable to create temp matter: " + OPERATION_NON_AUTHORIZED_MESSAGE)
      flash.now[:fatalerror] = get_localized_text(OPERATION_NON_AUTHORIZED_MESSAGE, true)
      @data = "##error**"
    rescue Exception => e
      log_exception_text("Unable to create temp matter: " + e.message)
      @data = "##error**"
    end
  end

  def validate_timecard_bill_status(  updated_timecard )

    uid = get_login
    pwd = get_pwd
    begin
      get_matter(uid, pwd, updated_timecard.matter_id)

      m                        = @matters.find { |mk, mv| mv.id == updated_timecard.matter_id}

      # TODO: Separate this nested ternary.

      is_non_billable          = ((m.nil? || m.count < 2 ? '' : m[1].is_non_billable) == 'yes') ? true : false
      is_timecard_non_billable = (updated_timecard.bill_status == 'Non-billable') ? true : false
      
      if is_non_billable && !is_timecard_non_billable
        return 'Bill status(Timecard with non-billable matter must be non-billable)'
      else
        return ''
      end
    rescue Exception => e
      log_exception_text("Unable to validate timecard bill status: " + e.message)
      flash.now[:fatalerror] = get_localized_text(GENERIC_FATAL_ERROR_MESSAGE, true)
    end

  end

end