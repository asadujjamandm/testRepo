module Matter_Utils
  def self.make_matter_post_data(postdata, m,matter_id)
    postdata.merge!({"id" => matter_id})    #it disable now fro avoiding exception
    postdata.merge!({"matterName" => m.matter_name})
    postdata.merge!({"matterNickName" => m.matter_nick_name})
    postdata.merge!({"matterNumber" => m.matter_number})
    postdata.merge!({"clientID" => m.client_id})
    postdata.merge!({"isNonBillable" => m.is_non_billable})
    postdata.merge!({"isActive" => m.is_active})

    postdata.merge!({"openDate" => m.open_date})
    postdata.merge!({"closeDate" => m.close_date})

    postdata.merge!({"matterDescription" => m.matter_description})
    postdata.merge!({"isTempMatter" => m.is_temp_matter})

    postdata.merge!({"narrative" => m.narrative})
    postdata.merge!({"isNoCharge" => m.is_no_charge})
    postdata.merge!({"isAdmin" => m.is_admin})
    postdata.merge!({"isProBono" => m.is_pro_bono})
    postdata.merge!({"isMaster" => m.is_master})
    postdata.merge!({"defaultTimeIncrement" => m.default_time_increment})
    postdata.merge!({"defaultMarkup" => m.default_markup})
    postdata.merge!({"relatedMatterID" => m.related_matter_id})
    postdata.merge!({"parentMatterID" => m.parent_matter_id})
    postdata.merge!({"clientContactID" => m.client_contact_id})
    postdata.merge!({"defaultTimekeeperID" => m.default_timekeeper_id})
    postdata.merge!({"supervisingTkprID" => m.supervising_tkpr_id})
    postdata.merge!({"matterRateID" => m.matter_rate_id})
    postdata.merge!({"matterLanguageID" => m.matter_language_id})
    postdata.merge!({"matterTypeID" => m.matter_type_id})
    postdata.merge!({"timeTaxID" => m.time_tax_id})
    postdata.merge!({"costTaxID" => m.cost_tax_id})
    postdata.merge!({"chargeTaxID" => m.charge_tax_id})
    postdata.merge!({"unit" => m.unit})
    postdata.merge!({"mT_UDF0" => m.mt_udf0})
    postdata.merge!({"mT_UDF1" => m.mt_udf1})
    postdata.merge!({"mT_UDF2" => m.mt_udf2})
    postdata.merge!({"mT_UDF3" => m.mt_udf3})
    postdata.merge!({"mT_UDF4" => m.mt_udf4})
    postdata.merge!({"mT_UDF5" => m.mt_udf5})
    postdata.merge!({"mT_UDF6" => m.mt_udf6})
    postdata.merge!({"mT_UDF7" => m.mt_udf7})
    postdata.merge!({"mT_UDF8" => m.mt_udf8})
    postdata.merge!({"mT_UDF9" => m.mt_udf9})
    postdata.merge!({"matterCurrencyID" => m.matter_currency_id})
    postdata.merge!({"isPosted" => 'no'})     # default value that needed to process on service
    postdata.merge!({"userID" => m.user_id})
    postdata.merge!({"matterID" => matter_id})
    postdata.merge!({"ErpMatterID" => '0'})     # default value that needed to process on service
    postdata.merge!({"createddate" => m.created_date})
    postdata.merge!({"modifieddate" => m.modified_date})

  end
  #matter_number
  def self.make_matter(params_matter, updated_matter)
    updated_matter.id = params_matter[:updated_matter_id].nil? ? updated_matter.id : params_matter[:updated_matter_id]
    updated_matter.matter_name = params_matter[:matter_name].nil? ? updated_matter.matter_name : params_matter[:matter_name]
    updated_matter.matter_nick_name = params_matter[:matter_nick_name].nil? ? updated_matter.matter_nick_name : params_matter[:matter_nick_name]
    updated_matter.client_id = params_matter[:client_id].nil? ? updated_matter.client_id : params_matter[:client_id]
    updated_matter.matter_number = params_matter[:matter_number].nil? ? updated_matter.matter_number : params_matter[:matter_number]
    updated_matter.is_non_billable = params_matter[:is_non_billable].nil? ? updated_matter.is_non_billable : params_matter[:is_non_billable]
    updated_matter.is_active = params_matter[:is_active].nil? ? updated_matter.is_active : params_matter[:is_active]
    updated_matter.mt_udf9 = params_matter[:mt_udf9].nil? ? updated_matter.mt_udf9 : params_matter[:mt_udf9]
    return updated_matter
  end
  def self.make_search_object(so, param_su)
    if so.nil?
      so = MatterSearch.new
    end
    if !param_su.nil?
      so.matter_number = param_su[:matter_number].nil? ? '' : param_su[:matter_number]
      so.matter_name = param_su[:matter_name].nil? ? '' : param_su[:matter_name]
    end
    return so
  end

end