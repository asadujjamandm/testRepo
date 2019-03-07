module TimekeeperUtils
  def self.make_timekeeper_post_data(postdata, t)
    postdata.merge!({"timekeeperid" => t.id})
    puts t.id.to_s
    postdata.merge!({"timekeepernumber" => t.timekeeper_number})
    #postdata.merge!({"userid" => user_id})
    postdata.merge!({"displayname" => t.display_name})
    postdata.merge!({"billname" => t.bill_name})
    postdata.merge!({"isactive" => t.is_active})
  end


  def self.make_timekeeper(params_timekeepers, updated_timekeeper)
    updated_timekeeper.id = params_timekeepers[:id].nil? ? updated_timekeeper.id : params_timekeepers[:id]
    puts updated_timekeeper.id
    updated_timekeeper.timekeeper_number = params_timekeepers[:timekeeper_number].nil? ? updated_timekeeper.timekeeper_number : params_timekeepers[:timekeeper_number]
    #updated_timekeeper.user_id = user_id
    updated_timekeeper.display_name = params_timekeepers[:display_name].nil? ? updated_timekeeper.display_name : params_timekeepers[:display_name]
    updated_timekeeper.bill_name = params_timekeepers[:bill_name].nil? ? updated_timekeeper.bill_name : params_timekeepers[:bill_name]
    updated_timekeeper.is_active = params_timekeepers[:is_active].nil? ? updated_timekeeper.is_active : params_timekeepers[:is_active]
    return updated_timekeeper
  end

  def self.make_search_object(so, param_su)
    if so.nil?
      so = TimekeeperSearch.new
    end
    if !param_su.nil?
      so.timekeeper_number = param_su[:timekeeper_number].nil? ? '' : param_su[:timekeeper_number]
      so.display_name = param_su[:display_name].nil? ? '' : param_su[:display_name]
    end
    return so
  end

end