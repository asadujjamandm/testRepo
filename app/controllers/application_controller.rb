class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :before_render
  
  include AuthsHelper

  def before_render
    if Rails.application.config.consider_all_requests_local
      p controller_name
      p action_name
    end
  end

  unless Rails.application.config.consider_all_requests_local
    #TODO: uncomment following lines in production
    rescue_from Exception, :with => :render_error
    rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found
    rescue_from ActionController::RoutingError, :with => :render_not_found
    rescue_from ActionController::UnknownController, :with => :render_not_found
    rescue_from ActionController::UnknownAction, :with => :render_not_found
  end

  def method_missing(m, *args, &block)
    render_not_found(Exception.new('Routing error for action: ' + m.to_s))
  end

  def render_not_found(exception)
    set_view_properties
    log_exception(exception)
    render :template => "/errors/404.html.erb", :status => 404, :layout=> false
  end

  def render_error(exception)
    set_view_properties
    log_exception(exception)
    render :template => "/errors/500.html.erb", :status => 500, :layout=> false
  end

  def log_exception(exception)
    Utils.log_exception(exception)
  end

  def log_exception_text(exception)
    Utils.log_exception_text(exception)
  end

  def log(message)
    Utils.log(message)
  end

  private
  def set_view_properties
    @title            = "Error"
    @pageheader       = @title
    @pageheader_image = 'error.png'
  end
end