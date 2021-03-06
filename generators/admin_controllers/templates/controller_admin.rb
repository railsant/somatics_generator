# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class Admin::AdminController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password
  
  include UserAuthenticatedSystem
  before_filter :user_login_required
  
  layout Proc.new { |c| c.request.format.js? ? false : 'admin' }
end
