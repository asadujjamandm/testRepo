source 'http://rubygems.org'

gem 'rails', '3.0.8'
gem 'rake', '0.9.2.2'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'recaptcha', :require => 'recaptcha/rails'
gem 'httparty', '0.7.4'
gem 'will_paginate', '3.0.pre2'
gem 'prawn', '0.8.4'
gem 'figaro'
gem 'quickeebooks'
gem 'oauth-plugin'
#gem 'email_verifier'
#run the following command to install prawnto (not used here) >> rails plugin install git://github.com/thorny-sun/prawnto.git

group :development do
  gem 'sqlite3-ruby', :require => 'sqlite3'
end

group :test do
  gem 'sqlite3-ruby', :require => 'sqlite3'
end

group :production, :staging do
  # heroku doesn't support sqlite
  # gem 'sqlite3-ruby', :require => 'sqlite3'
  gem 'mongrel', '1.2.0.pre2'
end

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
#   gem 'webrat'
# end
