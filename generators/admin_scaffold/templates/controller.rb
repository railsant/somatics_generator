class <%= controller_class_name %>Controller < Admin::AdminController
<% if options[:authenticated] -%>
  # Be sure to include AuthenticationSystem in Application Controller instead
  include <%= class_name %>AuthenticatedSystem
<% end -%>
  layout Proc.new { |c| c.request.format.js? ? false : 'admin' }
  
  # Add Redmine Filter Here
  # available_filters "id",  {:name => 'Ref No', :type => :integer, :order => 1}
  # defaut_filter "id", '='

  # GET /<%= table_name %>
  # GET /<%= table_name %>.xml
  def index
    @fields = <%= attributes.collect {|attribute| attribute.name}.inspect %>
    @headers = <%= attributes.collect {|attribute| attribute.name.humanize}.inspect %>
    respond_to do |format|
      format.html {
        @<%= table_name %> = <%= class_name %>.paginate(:page => params[:page], :conditions => query_statement, :order => (params[:sort].gsub('_reverse', ' DESC') unless params[:sort].blank?))
      }
      format.xml { 
        @<%= table_name %> = <%= class_name %>.all(:conditions => query_statement)
      }
      format.csv {
        @<%= table_name %> = <%= class_name %>.all(:conditions => query_statement)
        csv_string = FasterCSV.generate do |csv|
        	csv << @headers
        	@<%= table_name %>.each do |<%= singular_name %>|
        	  csv << @fields.collect { |f| <%= singular_name %>.send(f) }        	    
      	  end
      	end
      	send_data csv_string, :type => 'text/csv; charset=iso-8859-1; header=present', 
  				:disposition => "attachment; filename=<%= table_name %>.csv"
      }
      format.xls {
        @<%= table_name %> = <%= class_name %>.all(:conditions => query_statement)
        render :xls => @<%= table_name %>
      }
      format.pdf {
        params[:fields] = @fields
        @<%= table_name %> = <%= class_name %>.all(:conditions => query_statement)
        prawnto :prawn => {:text_options => { :wrap => :character }, :page_layout => :portrait }
      }
    end
  end

  # GET /<%= table_name %>/1
  # GET /<%= table_name %>/1.xml
  def show
    @<%= file_name %> = <%= class_name %>.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @<%= file_name %> }
    end
  end

  # GET /<%= table_name %>/new
  # GET /<%= table_name %>/new.xml
  def new
    @<%= file_name %> = <%= class_name %>.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @<%= file_name %> }
    end
  end

  # GET /<%= table_name %>/1/edit
  def edit
    @<%= file_name %> = <%= class_name %>.find(params[:id])
  end

  # POST /<%= table_name %>
  # POST /<%= table_name %>.xml
  def create
    @<%= file_name %> = <%= class_name %>.new(params[:<%= file_name %>])

    respond_to do |format|
      if @<%= file_name %>.save
        flash[:notice] = '<%= class_name %> was successfully created.'
        format.html { redirect_to([:admin,@<%= file_name %>]) }
        format.xml  { render :xml => @<%= file_name %>, :status => :created, :location => @<%= file_name %> }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @<%= file_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /<%= table_name %>/1
  # PUT /<%= table_name %>/1.xml
  def update
    @<%= file_name %> = <%= class_name %>.find(params[:id])

    respond_to do |format|
      if @<%= file_name %>.update_attributes(params[:<%= file_name %>])
        flash[:notice] = '<%= class_name %> was successfully updated.'
        format.html { redirect_to([:admin,@<%= file_name %>]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @<%= file_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /<%= table_name %>/1
  # DELETE /<%= table_name %>/1.xml
  def destroy
    @<%= file_name %> = <%= class_name %>.find(params[:id])
    @<%= file_name %>.destroy
    flash[:notice] = '<%= class_name %> was successfully deleted.'
    respond_to do |format|
      format.html { redirect_to(admin_<%= table_name %>_url) }
      format.xml  { head :ok }
    end
  end
  
  # def bulk
  #   unless params[:ids].blank?
  #     <%= table_name %> = <%= class_name %>.find(params[:ids])
  #     success = true
  #     params[:<%= file_name %>].delete_if {|k, v| v.blank?}
  #     <%= table_name %>.each do |<%= file_name %>|
  #       success &&= <%= file_name %>.update_attributes(params[:<%= file_name %>])
  #     end
  #     success ? flash[:notice] = '<%= class_name.pluralize %> were successfully updated.' : flash[:error] = 'Bulk Update Failed.'
  #   else
  #     flash[:error] = 'No <%= class_name %> record is selected.'
  #   end
  #   
  #   respond_to do |format|
  #     format.html { redirect_to(admin_<%= table_name %>_path) }
  #     format.xml  { head :ok }
  #   end
  # end
  
<% if options[:authenticated] -%>
  def signup
    @<%= file_name %> = <%= class_name %>.new
  end

  def register
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
<% end -%>
end
