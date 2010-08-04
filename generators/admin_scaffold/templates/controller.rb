class <%= controller_class_name %>Controller < Admin::AdminController
<% if options[:admin_authenticated] -%>
  # Be sure to include AuthenticationSystem in Application Controller instead
  include <%= class_name %>AuthenticatedSystem
<% end -%>
  
  # Redmine Filters
  available_filters :id,  {:name => 'ID', :type => :integer, :order => 1}
  <% attributes.each_with_index do |attribute, index| -%>
  # available_filters :<%=attribute.name%>,  {:name => '<%=attribute.name.humanize%>', :type => :<%=attribute.type%>, :order => <%=index%>}
  <% end -%>

  default_filter :id
  <% attributes.each do |attribute| -%>
  # default_filter :<%=attribute.name%>
  <% end %>

  # GET /<%= table_name %>
  # GET /<%= table_name %>.xml
  def index
    @fields = <%= attributes.collect {|attribute| attribute.name}.inspect %>
    @headers = <%= attributes.collect {|attribute| attribute.name.humanize}.inspect %>
    respond_to do |format|
      format.html {
        @<%= table_name %> = <%= class_name %>.paginate(:page => params[:<%= table_name %>_page], :conditions => query_statement, :order => (params[:<%= singular_name %>_sort].gsub('_reverse', ' DESC') unless params[:<%= singular_name %>_sort].blank?))
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
        format.html { redirect_to(params[:return_to] || [:admin,@<%= file_name %>]) }
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
end
