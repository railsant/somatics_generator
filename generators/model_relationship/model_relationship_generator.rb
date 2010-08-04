class ModelRelationshipGenerator < Rails::Generator::NamedBase
  default_options :skip_migration => false,
                  :skip_views => false
  attr_reader :relationship, :reference_value
  attr_reader :model_name, :class_name
  attr_reader :reference_model_name, :reference_class_name
  attr_reader :migration_table_name, :migration_attribute

  def initialize(runtime_args, runtime_options = {})
    super
    
    @runtime_args = runtime_args
    @command = @runtime_args.first
    raise banner unless match_data = @command.match(/(.*)_(has_many|belongs_to)_(.*)/)
    @relationship = match_data[2]
    @model_name = match_data[1].singularize
    @class_name = @model_name.camelize
    @reference_model_name = match_data[3].singularize
    @reference_class_name = @reference_model_name.camelize
    case @relationship
      when 'has_many'
        @reference_value = @reference_model_name.pluralize
        @migration_model_name = @reference_model_name
        @migration_table_name = @reference_value
        @migration_attribute = "#{@model_name}_id"
      when 'belongs_to'
        # @reference_value = @reference_model_name
        # @migration_model_name = @model_name
        # @migration_table_name = @model_name.pluralize
        # @migration_attribute = "#{@reference_model_name}_id"
    end
  end
  
  def manifest
    record do |m|
      if relationship == 'has_many'
        m.add_relationship_to_model
        m.add_list_view_to_model_show
        m.add_show_view_to_model_show
        m.dependency 'admin_attributes', [@migration_model_name, "#{migration_attribute}:integer"], :skip_migration => true unless options[:skip_views]
        # raise 'migration_exists' if m.migration_exists?("add_#{migration_attribute}_to_#{migration_table_name}")
        unless options[:skip_migration] 
          m.migration_template 'migration.rb', "db/migrate", {
            :assigns => {
              :migration_name => "add_#{migration_attribute}_to_#{migration_table_name}",
              :table_name => migration_table_name,
              :attribute => migration_attribute
            },
            :migration_file_name => "add_#{migration_attribute}_to_#{migration_table_name}"
          }
        end
      end
    end
  end
  
  protected
  
  # Override with your own usage banner.
  def banner
    "Usage: #{$0} model_relationship ModelA_has_many_ModelBs/ModelA_belongs_to_ModelB"
  end
  
  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("--skip-migration",
           "Don't generate a migration file for this relationship") { |v| options[:skip_migration] = v }
    opt.on("--skip-views",
           "Don't update views for this relationship") { |v| options[:skip_views] = v }
  end  
end

class Rails::Generator::Commands::Create
  def add_relationship_to_model
    relation = "has_many :#{reference_value}"
    sentinel = "class #{class_name} < ActiveRecord::Base\n"
    gsub_file File.join('app/models', "#{model_name}.rb"), /(#{Regexp.escape(sentinel)})/mi do |match|
      "#{match}  #{relation}\n"
    end
    logger.insert relation
    relation = "belongs_to :#{model_name}"
    sentinel = "class #{reference_class_name} < ActiveRecord::Base\n"
    gsub_file File.join('app/models', "#{reference_model_name}.rb"), /(#{Regexp.escape(sentinel)})/mi do |match|
      "#{match}  #{relation}\n"
    end
    logger.insert relation
  end
  
  def add_show_view_to_model_show
    sentinel = "<!-- More List View -->\n"
    reference_list = <<-CODE
<% if @#{reference_model_name}.#{model_name} %>
<h3><%=link_to "\#{#{class_name}.human_name} #\#{@#{reference_model_name}.#{model_name}.id}", [:admin, @#{reference_model_name}.#{model_name}] %></h3>
<div class="issue detail">
	<%= render :partial => 'admin/#{model_name.pluralize}/show' , :locals => {:#{model_name} => @#{reference_model_name}.#{model_name}} %>
</div>
<% end %>
    CODE
    gsub_file File.join('app/views/admin', reference_model_name.pluralize, 'show.html.erb'), /(#{Regexp.escape(sentinel)})/mi do |match|
      "#{match}#{reference_list}"
    end
    logger.update File.join('app/views/admin', model_name.pluralize, 'show.html.erb')
    gsub_file File.join('app/views/admin', reference_model_name.pluralize, 'edit.html.erb'), /(#{Regexp.escape(sentinel)})/mi do |match|
      "#{match}#{reference_list}"
    end
    logger.update File.join('app/views/admin', reference_model_name.pluralize, 'edit.html.erb')
  end
  
  def add_list_view_to_model_show
    sentinel = "<!-- More List View -->\n"
    reference_list = <<-CODE
<div class="contextual">
  <%= link_to "\#{t 'Add'} \#{#{reference_class_name}.human_name}", '#', :class => "icon icon-add", :onclick => "showAndScrollTo('add_#{reference_model_name}','focus_#{reference_model_name}'); return false;"%>
</div>
<h3><%=#{reference_class_name}.human_name%></h3>
<% @#{reference_value} = @#{model_name}.#{reference_value}.paginate(:page => params[:#{reference_model_name}_page], :order => (params[:#{reference_model_name}_sort].gsub('_reverse', ' DESC') unless params[:#{reference_model_name}_sort].blank?))%>
<div class="autoscroll">
  <%= render :partial => 'admin/#{reference_value}/list', :locals => {:#{reference_value} => @#{reference_value}} %>
</div>
<%= will_paginate @#{reference_value}, :renderer => SomaticLinkRenderer %>
<div id="add_#{reference_model_name}" style="display:none">
  <h3><%= "\#{t('New')} \#{#{reference_class_name}.human_name}" %></h3>
  <div id="focus_#{reference_model_name}"></div>
  <% form_for([:admin, @#{model_name}.#{reference_value}.build]) do |f| %>
    <%= f.error_messages %>
    <div class="issue">
      <%= render :partial => 'admin/#{reference_value}/form' , :locals => {:f => f} %>
    </div>
    <%= hidden_field_tag :return_to, url_for%>
    <%= f.submit t('Create') %>
  <% end %>
  <%= link_to_function t('Cancel'), "$('add_#{reference_model_name}').hide()"%>
</div>
CODE
    gsub_file File.join('app/views/admin', model_name.pluralize, 'show.html.erb'), /(#{Regexp.escape(sentinel)})/mi do |match|
      "#{match}#{reference_list}"
    end
    logger.update File.join('app/views/admin', model_name.pluralize, 'show.html.erb')
    gsub_file File.join('app/views/admin', model_name.pluralize, 'edit.html.erb'), /(#{Regexp.escape(sentinel)})/mi do |match|
      "#{match}#{reference_list}"
    end
    logger.update File.join('app/views/admin', model_name.pluralize, 'edit.html.erb')
  end
end

class Rails::Generator::Commands::Destroy
  def add_relationship_to_model
    look_for = "has_many :#{reference_value}"
    gsub_file File.join('app/models', "#{model_name}.rb"), /(#{Regexp.escape(look_for)})/mi, ''
    logger.remove look_for
    
    look_for = "belongs_to :#{reference_value}"
    gsub_file File.join('app/models', "#{reference_model_name}.rb"), /(#{Regexp.escape(look_for)})/mi, ''
    logger.remove look_for
  end
  
  def add_show_view_to_model_show
    look_for = <<-CODE
<% if @#{reference_model_name}.#{model_name} %>
<h3><%=link_to "\#{#{class_name}.human_name} #\#{@#{reference_model_name}.#{model_name}.id}", [:admin, @#{reference_model_name}.#{model_name}] %></h3>
<div class="issue detail">
	<%= render :partial => 'admin/#{model_name.pluralize}/show' , :locals => {:#{model_name} => @#{reference_model_name}.#{model_name}} %>
</div>
<% end %>
    CODE
        gsub_file File.join('app/views/admin', model_name.pluralize, 'show.html.erb'), /(#{Regexp.escape(look_for)})/mi, ''
        logger.revert File.join('app/views/admin', model_name.pluralize, 'show.html.erb')
        gsub_file File.join('app/views/admin', model_name.pluralize, 'edit.html.erb'), /(#{Regexp.escape(look_for)})/mi, ''
        logger.revert File.join('app/views/admin', model_name.pluralize, 'edit.html.erb')
  end
  
  def add_list_view_to_model_show
    look_for = <<-CODE
<div class="contextual">
  <%= link_to "\#{t 'Add'} \#{#{reference_class_name}.human_name}", '#', :class => "icon icon-add", :onclick => "showAndScrollTo('add_#{reference_model_name}','focus_#{reference_model_name}'); return false;"%>
</div>
<h3><%=#{reference_class_name}.human_name%></h3>
<% @#{reference_value} = @#{model_name}.#{reference_value}.paginate(:page => params[:#{reference_model_name}_page], :order => (params[:#{reference_model_name}_sort].gsub('_reverse', ' DESC') unless params[:#{reference_model_name}_sort].blank?))%>
<div class="autoscroll">
  <%= render :partial => 'admin/#{reference_value}/list', :locals => {:#{reference_value} => @#{reference_value}} %>
</div>
<%= will_paginate @#{reference_value}, :renderer => SomaticLinkRenderer %>
<div id="add_#{reference_model_name}" style="display:none">
  <h3><%= "\#{t('New')} \#{#{reference_class_name}.human_name}" %></h3>
  <div id="focus_#{reference_model_name}"></div>
  <% form_for([:admin, @#{model_name}.#{reference_value}.build]) do |f| %>
    <%= f.error_messages %>
    <div class="issue">
      <%= render :partial => 'admin/#{reference_value}/form' , :locals => {:f => f} %>
    </div>
    <%= hidden_field_tag :return_to, url_for%>
    <%= f.submit t('Create') %>
  <% end %>
  <%= link_to_function t('Cancel'), "$('add_#{reference_model_name}').hide()"%>
</div>
CODE
    gsub_file File.join('app/views/admin', model_name.pluralize, 'show.html.erb'), /(#{Regexp.escape(look_for)})/mi, ''
    logger.revert File.join('app/views/admin', model_name.pluralize, 'show.html.erb')
    gsub_file File.join('app/views/admin', model_name.pluralize, 'edit.html.erb'), /(#{Regexp.escape(look_for)})/mi, ''
    logger.revert File.join('app/views/admin', model_name.pluralize, 'edit.html.erb')
  end
end