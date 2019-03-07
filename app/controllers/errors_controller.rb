class ErrorsController < BaseController
  def routing
    render_not_found Exception.new('Routing error for controller: ' + params[:a])
  end
end