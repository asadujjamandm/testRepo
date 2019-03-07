module ForgetPasswordUtils
  def self.make_password_post_data(postdata, u)
    postdata.merge!({"reset_email" => u.email})
    postdata.merge!({"reset_firm_id" => u.firm_id})
    postdata.merge!({"reset_password" => u.password})
  end

end