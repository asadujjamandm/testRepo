module ActivitycodeUtils
  def self.make_activitycode_post_data(postdata, a)
    postdata.merge!({"activitycodeid" => a.id})
    puts a.id
    postdata.merge!({"activitycode" => a.activity_code})
    postdata.merge!({"activitydesc" => a.activity_desc})
    postdata.merge!({"activitycodestatus" => a.is_active})
  end


  def self.make_activitycode(params_activitycodes, updated_activitycode)
    updated_activitycode.id = params_activitycodes[:id].nil? ? updated_activitycode.id : params_activitycodes[:id]
    updated_activitycode.activity_code = params_activitycodes[:activity_code].nil? ? updated_activitycode.activity_code : params_activitycodes[:activity_code]
    updated_activitycode.activity_desc = params_activitycodes[:activity_desc].nil? ? updated_activitycode.activity_desc : params_activitycodes[:activity_desc]
    updated_activitycode.is_active = params_activitycodes[:is_active].nil? ? updated_activitycode.is_active : params_activitycodes[:is_active]
    return updated_activitycode
  end

  def self.make_search_object(so, param_su)
    if so.nil?
      so = ActivitycodeSearch.new
    end
    if !param_su.nil?
      so.activity_code = param_su[:activity_code].nil? ? '' : param_su[:activity_code]
      so.activity_desc = param_su[:activity_desc].nil? ? '' : param_su[:activity_desc]
    end
    return so
  end

end