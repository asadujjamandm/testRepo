require 'utils'
module TimecardUtils
  def self.get_search_query(search_object, date_localization_method, text_localization_method) #date_localization_method is a function/method pointer, like delegates, similarly text_localization_method
    query = {}
    filtered_by = ''

    if !search_object.matter.nil? && search_object.matter != ''
      filtered_by=join_filter filtered_by, ' Matter'
      query.merge!({NSI_SERVICE_PARAM_KEY_MATTERNUMBER => search_object.matter})
    end

    if !search_object.client.nil? && search_object.client != ''
      filtered_by=join_filter filtered_by, ' Client'
      query.merge!({NSI_SERVICE_PARAM_KEY_CLIENTNUMBER => search_object.client})
    end

    if !search_object.timekeeper.nil? && search_object.timekeeper != ''
      filtered_by=join_filter filtered_by, ' Timekeeper'
      query.merge!({NSI_SERVICE_PARAM_KEY_TIMEKEEPERNUMBER => search_object.timekeeper})
    end

    # TODO: Modify for timekeeper.name

    if !search_object.timekeeper_name.nil? && search_object.timekeeper_name != ''
      filtered_by=join_filter filtered_by, ' Timekeeper'
      query.merge!({NSI_SERVICE_PARAM_KEY_TIMEKEEPERNAME => search_object.timekeeper_name})
    end

    if !search_object.query_type.nil? && search_object.query_type!=''
      query.merge!({'query_type' => search_object.query_type})
    end

    if !search_object.from_date.nil? && search_object.from_date != ''
      if !search_object.to_date.nil?
        if search_object.from_date == search_object.to_date
          filtered_by=join_filter filtered_by, ' of ' + date_localization_method.call( Date.strptime( search_object.to_date ) )
        else
          filtered_by=join_filter filtered_by, ' between ' + date_localization_method.call( Date.strptime( search_object.from_date ) ) + ' and ' + date_localization_method.call( Date.strptime( search_object.to_date ) )
        end
      end
      query.merge!({NSI_SERVICE_PARAM_KEY_TCBILLDATEFROM => search_object.from_date})
    else
       filtered_by=join_filter filtered_by, ' of all date'
    end

    if !search_object.to_date.nil? && search_object.to_date != ''
      query.merge!({NSI_SERVICE_PARAM_KEY_TCBILLDATETO => search_object.to_date})
    end

    if !search_object.synced.nil? && search_object.synced != ''
      if search_object.synced=='Yes'
        filtered_by=join_filter filtered_by, ' synced'
      else
        filtered_by=join_filter filtered_by, ' chched'
      end
      query.merge!({NSI_SERVICE_PARAM_KEY_TCSYNCED => (search_object.synced=='Yes' ? '1' :'0')})
    end

    if !search_object.bill_status.nil? && search_object.bill_status != ''
      if search_object.bill_status == "Billable"
        filtered_by=join_filter filtered_by, ' billable'
        query.merge!({NSI_SERVICE_PARAM_KEY_TCBILLSTATUS => search_object.bill_status})
      elsif search_object.bill_status == "Posted"
        #do nothing
      elsif search_object.bill_status == ""
         #do nothing
      else
        filtered_by=join_filter filtered_by, ' non-billable'
        query.merge!({NSI_SERVICE_PARAM_KEY_TCBILLSTATUS => search_object.bill_status})
      end
    end

    if !search_object.approved.nil? && search_object.approved != ''
      if search_object.approved == 'Yes'
        filtered_by = join_filter(filtered_by, ' posted')
      else
        filtered_by = join_filter(filtered_by, ' pending')
      end
      query.merge!({NSI_SERVICE_PARAM_KEY_TCAPPROVED => (search_object.approved=='Yes' ? '1' :'0')})
    end

    search_text = search_object.search_text

    if !( search_text.nil? || search_text == "" )
      search_text_in_base_locale =   text_localization_method.call( search_text, false )
      #matter
      filtered_by=join_filter(filtered_by, ' searched text: ' + search_text)
      query.merge!({NSI_SERVICE_PARAM_KEY_MATTERNUMBER => search_text})
      #client
      query.merge!({NSI_SERVICE_PARAM_KEY_CLIENTNUMBER => search_text})
      #timekeeper
      query.merge!({NSI_SERVICE_PARAM_KEY_TIMEKEEPERNUMBER => search_text})
      # TOOD: Revert
      query.merge!({NSI_SERVICE_PARAM_KEY_TIMEKEEPERNAME => search_text})
      #narrative
      query.merge!({NSI_SERVICE_PARAM_KEY_NARRATIVE => search_text_in_base_locale})
      #template
      query.merge!({NSI_SERVICE_PARAM_KEY_INTERNAL_COMMENT => search_text_in_base_locale})
    end

    return query, filtered_by
  end

  def self.get_user_query(search_object, text_localization_method)
    query = {}
    filtered_by = ''

    if !search_object.timekeeper_name.nil? && search_object.timekeeper_name != ''
      filtered_by=join_filter filtered_by, ' Timekeeper'
      query.merge!({NSI_SERVICE_PARAM_KEY_TIMEKEEPERNAME => search_object.timekeeper_name})
    end

    if !search_object.query_type.nil? && search_object.query_type!=''
      query.merge!({'query_type' => search_object.query_type})
    end

    search_text = search_object.search_text

    if !(search_text.nil? || search_text == "")
      search_text_in_base_locale =   text_localization_method.call( search_text, false )
      #matter
      filtered_by=join_filter(filtered_by, ' searched text: ' + search_text)

      query.merge!({NSI_SERVICE_PARAM_KEY_TIMEKEEPERNAME => search_text})
    end

    return query, filtered_by
  end

  def self.make_timecard(timecards, params_timecards, user_id, updated_timecards)
    updated_timecard_id = params_timecards.nil? ? nil : params_timecards[:updated_timecard_id]
    if !updated_timecard_id.nil?
      if updated_timecard_id != ''
        if( updated_timecards.size >= 1 )
          foundOne = updated_timecards.find { |k, v| v.id == updated_timecard_id }
          if( foundOne.nil? )
              updated_timecard = timecards.find { |k, v| v.id == updated_timecard_id }[1]
          else
            updated_timecard = foundOne[1]
          end
        else
          foundOne  = timecards.find { |k, v| v.id == updated_timecard_id }
          if( !foundOne.nil? )
            updated_timecard = foundOne[1]
          else
            raise 'Invalid timecard to update'
          end
        end
      else
        updated_timecard = Timecard.new
      end
      updated_timecard.matter_id = get_updated_object(params_timecards, :matter_id)
      updated_timecard.client_id = get_updated_object(params_timecards, :client_id)
      updated_timecard.template = get_updated_object(params_timecards, :template)
      updated_timecard.description = get_updated_object(params_timecards, :description)
      updated_timecard.timekeeper_id = get_updated_object(params_timecards, :timekeeper_id)
      updated_timecard.hours = Utils.get_seconds_from_time get_updated_object(params_timecards, :hours)
      updated_timecard.units = get_units_value(params_timecards)
      updated_timecard.hhmm = get_updated_object(params_timecards, :hhmm)
      updated_timecard.date = get_updated_object(params_timecards, :date)
      #updated_timecard.bill_status = get_updated_object(params_timecards, :bill_status)    changed due to new requirement of billable selection in timecard create page
      updated_timecard.bill_status = get_updated_object(params_timecards, :billable_status)
      updated_timecard.message = get_updated_object(params_timecards, :message)
      updated_timecard.is_dirty_confirmed = true
      updated_timecard.user_id = user_id
      updated_timecard.internal_comment =  get_updated_object(params_timecards, :internal_comment)
      updated_timecard.activity_id = get_updated_object(params_timecards, :activity_id)
      return updated_timecard
    else
      return nil
    end
  end

  def self.get_units_value(params_timecards)
    units = get_updated_object(params_timecards, :units)
    unit_type = get_updated_object(params_timecards, :unit_type)

    if unit_type == 'Minute'
      return Utils.get_seconds_from_minute units
    elsif unit_type == 'Hour'
      return Utils.get_seconds_from_hour units
    else
      return units
    end
  end

  def self.make_search_object(search_object, param_search_timecard)
    if search_object.nil?
      search_object = TimecardSearch.new
    end

    if !param_search_timecard.nil?
      #search_object.matter = param_search_timecard[:matter].nil? ? '' : param_search_timecard[:matter]
      #search_object.client = param_search_timecard[:client].nil? ? '' : param_search_timecard[:client]
      #search_object.timekeeper = param_search_timecard[:timekeeper].nil? ? '' : param_search_timecard[:timekeeper]
      search_object.date_range = ((param_search_timecard[:date_range].nil?) or (param_search_timecard[:date_range]=="Pick Date Range"))? '' : param_search_timecard[:date_range]
      if search_object.date_range == ''
        search_object.from_date = param_search_timecard[:from_date].nil? ? '' : param_search_timecard[:from_date]
        search_object.to_date   = param_search_timecard[:to_date].nil? ? '' : param_search_timecard[:to_date]
      else
        search_object.from_date = search_object.date_range.to_s.split(" - ")[0];
        search_object.to_date   = search_object.date_range.to_s.split(" - ")[1];
      end

      search_object.bill_status = param_search_timecard[:bill_status].nil? ? '' : param_search_timecard[:bill_status]
      search_object.approved    = param_search_timecard[:approved].nil? ? '' : param_search_timecard[:approved]
      search_object.synced      = param_search_timecard[:synced].nil? ? '' : param_search_timecard[:synced]
      search_object.search_text = param_search_timecard[:search_text].nil? ? '' : param_search_timecard[:search_text]
      search_object.matter      = param_search_timecard[:matter].nil? ? '' : param_search_timecard[:matter]

      # Added for timecard report filtering based on client, matter, timekeeper
      search_object.client = param_search_timecard[:client_number].nil? ? '' : param_search_timecard[:client_number].to_s.split(" - ")[0]
      search_object.matter = param_search_timecard[:matter_number].nil? ? '' : param_search_timecard[:matter_number].to_s.split(" - ")[0]
      search_object.timekeeper = param_search_timecard[:timekeeper_number].nil? ? '' : param_search_timecard[:timekeeper_number].to_s.split(" - ")[0]

      # TODO: Revert

      search_object.timekeeper_name = param_search_timecard[:timekeeper_name].nil? ? '' : param_search_timecard[:timekeeper_name].to_s.split(" - ")[0]
      search_object.query_type = param_search_timecard[:query_type].nil? ? '' : param_search_timecard[:query_type].to_s     #search timecards by joining filters using and/or. default and


      if ( !param_search_timecard[:additional].nil? )
        text = param_search_timecard[:additional]
        search_object.bill_status = ""
        search_object.approved = ""
        search_object.synced = ""
        if text.upcase == "ALL"
          #do nothing
        elsif text.upcase == "POSTED"
          search_object.bill_status = "Posted"
          search_object.approved = "Yes"
        elsif text.upcase == "NOT-POSTED"
          search_object.approved = "No"
        elsif text.upcase == "BILLABLE"
          search_object.bill_status = "Billable"
        elsif text.upcase == "NON-BILLABLE"
          search_object.bill_status = "Non-Billable"
        elsif text.upcase == "SYNCED"
          search_object.synced = "Yes"
        elsif text.upcase == "NOT-SYNCED"
          search_object.synced = "No"
        end
      end
    end

    return search_object

  end

  private
  def self.join_filter(filtered_by, new_filter)
    if (filtered_by != '')
      return filtered_by+=(', '+new_filter)
    else
      return new_filter
    end
  end

  def self.get_updated_object(params_timecards, p)
    params_timecards[p].nil? ? '' : params_timecards[p]
  end
end