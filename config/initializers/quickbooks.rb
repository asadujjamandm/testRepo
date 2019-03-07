=begin
QB_KEY = "qyprduVs2Gcg464lBhEUxhlhgIoyfr"
QB_SECRET = "s36alyW4clRFMq6MnhR6IQsUMUTAv3IxkNv0lsAz"

$qb_oauth_consumer = OAuth::Consumer.new(QB_KEY, QB_SECRET, {
    :site                 => "https://oauth.intuit.com",
    :request_token_path   => "/oauth/v1/get_request_token",
    :authorize_url        => "https://appcenter.intuit.com/Connect/Begin",
    :access_token_path    => "/oauth/v1/get_access_token"
})
=end
