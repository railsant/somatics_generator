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
        @reference_value = @reference_model_name
        @migration_model_name = @model_name
        @migration_table_name = @model_name.pluralize
        @migration_attribute = "#{@reference_model_name}_id"
    end
  end
  
  def manifest
    record do |m|
      m.add_relationship_to_model
      m.add_list_view_to_model_show if relationship == 'has_many'
      m.dependency 'admin_attributes', [@migration_model_name, "#{migration_attribute}:integer"], :skip_migration => true unless options[:skip_views]
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
    relation = "#{relationship} :#{reference_value}"
    sentinel = "class #{class_name} < ActiveRecord::Base\n"
    gsub_file File.join('app/models', "#{model_name}.rb"), /(#{Regexp.escape(sentinel)})/mi do |match|
      "#{match}  #{relation}\n"
    end
    logger.insert relation
  end
  
  def add_list_view_to_model_show
    sentinel = "<!-- More List View -->\n"
    reference_list = "<h3>#{reference_model_name.humanize} List</h3>\n<%= render :partial => 'admin/#{reference_value}/list', :locals => {:#{reference_value} => @#{model_name}.#{reference_value}.all(:page => params[:#{reference_model_name}_page], :order => (params[:#{refence_model_name}_sort].gsub('_reverse', ' DESC') unless params[:#{refence_model_name}_sort].blank?))} %>\n"
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
  def add_relationship_to_models
    look_for = "#{relationship} :#{reference_value}"
    gsub_file File.join('app/models', "#{model_name}.rb"), /(#{Regexp.escape(look_for)})/mi, ''
    logger.remove look_for
  end
  
  def add_list_view_to_model_show
    look_for = "<h3>#{reference_model_name.humanize} List</h3>\n<%= render :partial => 'admin/#{reference_value}/list', :locals => {:#{reference_value} => @#{model_name}.#{reference_value}.all(:page => params[:#{reference_model_name}_page], :order => (params[:#{refence_model_name}_sort].gsub('_reverse', ' DESC') unless params[:#{refence_model_name}_sort].blank?))} %>\n"
    gsub_file File.join('app/views/admin', model_name.pluralize, 'show.html.erb'), /(#{Regexp.escape(look_for)})/mi, ''
    logger.revert File.join('app/views/admin', model_name.pluralize, 'show.html.erb')
    gsub_file File.join('app/views/admin', model_name.pluralize, 'edit.html.erb'), /(#{Regexp.escape(look_for)})/mi, ''
    logger.revert File.join('app/views/admin', model_name.pluralize, 'edit.html.erb')
  end
end