class <%= controller_plural_name.camelize %>Controller < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include <%= class_name %>AuthenticatedSystem
  
  skip_before_filter :<%= file_name %>_login_required

  def new
    @<%= file_name %> = <%= class_name %>.new
  end

  def create
    <%= file_name %>_logout_keeping_session!
    @<%= file_name %> = <%= class_name %>.new(params[:<%= file_name %>])
<% if options[:stateful] -%>
    @<%= file_name %>.register! if @<%= file_name %> && @<%= file_name %>.valid?
    success = @<%= file_name %> && @<%= file_name %>.valid?
<% else -%>
    success = @<%= file_name %> && @<%= file_name %>.save
<% end -%>
    if success && @<%= file_name %>.errors.empty?
<% if !options[:include_activation] -%>
      # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset session
      self.current_<%= file_name %> = @<%= file_name %> # !! now logged in
<% end -%>
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      render :action => 'signup'
    end
  end

<% if options[:include_activation] -%>
  def activate
    <%= file_name %>_logout_keeping_session!
    <%= file_name %> = <%= class_name %>.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
      when (!params[:activation_code].blank?) && <%= file_name %> && !<%= file_name %>.active?
        <%= file_name %>.activate!
        flash[:notice] = "Signup complete! Please sign in to continue."
        redirect_to "/#{controller_plural_name}/login"
      when params[:activation_code].blank?
        flash[:error] = "The activation code was missing.  Please follow the URL from your email."
        redirect_back_or_default('/')
      else 
        flash[:error]  = "We couldn't find a <%= file_name %> with that activation code -- check your email? Or maybe you've already activated -- try signing in."
        redirect_back_or_default('/')
      end
    end
  end
<% end -%>
end