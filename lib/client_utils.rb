module Client_Utils
  def self.make_client_post_data(postdata, c,client_id)
    postdata.merge!({"id" => client_id})    #it disable now fro avoiding exception
    postdata.merge!({"clientname" => c.client_name})
    postdata.merge!({"displayname" => c.display_name})
    postdata.merge!({"isactive" => c.is_active})
    postdata.merge!({"cl_udf9" => c.cl_udf9})
  end

  def self.make_client(params_client, updated_client)
    updated_client.id = params_client[:updated_client_id].nil? ? updated_client.id : params_client[:updated_client_id]
    updated_client.client_name = params_client[:client_name].nil? ? updated_client.client_name : params_client[:client_name]
    updated_client.display_name = params_client[:display_name].nil? ? updated_client.display_name : params_client[:display_name]
    updated_client.is_active = params_client[:is_active].nil? ? updated_client.is_active : params_client[:is_active]
    updated_client.cl_udf9 = params_client[:cl_udf9].nil? ? updated_client.cl_udf9 : params_client[:cl_udf9]
    return updated_client
  end
  def self.make_search_object(so, param_su)
    if so.nil?
      so = ClientSearch.new
    end
    if !param_su.nil?
      so.client_number = param_su[:client_number].nil? ? '' : param_su[:client_number]
      so.client_name = param_su[:client_name].nil? ? '' : param_su[:client_name]
    end
    return so
  end
end