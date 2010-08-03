class AdminSettingGenerator < AdminScaffoldGenerator
  def initialize(runtime_args, runtime_options = {})
    super ['setting', 'name:string', 'field_type:string', 'value:text', 'category:string', 'description:text', 'mce_editable:boolean'], runtime_options
  end

  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions("#{controller_class_name}Controller", "#{controller_class_name}Helper")
      m.class_collisions(class_name)

      # Controller, helper, views, test and stylesheets directories.
      m.directory(File.join('app/models', class_path))
      m.directory(File.join('app/controllers', controller_class_path))
      m.directory(File.join('app/helpers', controller_class_path))
      m.directory(File.join('app/views', controller_class_path, controller_file_name))
      m.directory(File.join('app/views', controller_class_path, "shared"))
      m.directory(File.join('test/functional', controller_class_path))
      m.directory(File.join('test/unit', class_path))
      m.directory(File.join('test/unit/helpers', controller_class_path))
      
      m.template 'controller.rb', File.join('app/controllers', controller_class_path, "#{controller_file_name}_controller.rb")
      m.template 'helper.rb',     File.join('app/helpers',     controller_class_path, "#{controller_file_name}_helper.rb")
      m.template 'model.rb',      File.join('app/models',      class_path,            "#{file_name}.rb")
      
      # Views and Builders
      m.template "partial_form.html.erb", File.join('app/views', controller_class_path, controller_file_name, "_form.html.erb")
      m.template "partial_list.html.erb", File.join('app/views', controller_class_path, controller_file_name, "_list.html.erb")
      m.template "partial_show.html.erb", File.join('app/views', controller_class_path, controller_file_name, "_show.html.erb")
      m.template "partial_edit.html.erb", File.join('app/views', controller_class_path, controller_file_name, "_edit.html.erb")
      m.template "view_index.html.erb",   File.join('app/views', controller_class_path, controller_file_name, "index.html.erb")
      m.template "view_show.html.erb",    File.join('app/views', controller_class_path, controller_file_name, "show.html.erb")
      m.template "view_edit.html.erb",    File.join('app/views', controller_class_path, controller_file_name, "edit.html.erb")
      m.template "builder_index.xml.builder", File.join('app/views', controller_class_path, controller_file_name, "index.xml.builder")
      m.template "builder_index.xls.builder", File.join('app/views', controller_class_path, controller_file_name, "index.xls.builder")
      m.template "builder_index.pdf.prawn",   File.join('app/views', controller_class_path, controller_file_name, "index.pdf.prawn")
      
      # Locales templates 
      %w( en zh-TW ).each do |locale|
        m.template "locales_#{locale}.yml", File.join('config/locales', "#{controller_file_name}_#{locale}.yml")
      end

      # Application, Layout and Stylesheet and Javascript.
      m.header_menu(controller_file_name)

      m.admin_route_setting
      
      m.migration_template 'migration.rb', "db/migrate", {
        :assigns => {
          :migration_name => "Create#{class_name.pluralize.gsub(/::/, '')}",
        }, :migration_file_name => "create_#{file_path.gsub(/\//, '_').pluralize}"
      }
    end
  end
  
  protected
  
  def banner
    "Usage: #{$0} admin_setting"
  end  
end

class Rails::Generator::Commands::Create
  def admin_route_setting
    setting = ":#{table_name}, :only => [:index, :show, :edit, :update]"
    sentinel = 'map.namespace(:admin) do |admin|'

    logger.route "admin.resources #{setting}"
    unless options[:pretend]
      gsub_file 'config/routes.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
        "#{match}\n    admin.resources #{setting}"
      end
    end
  end
end

class Rails::Generator::Commands::Destroy
  def admin_route_setting
    setting = ":#{table_name}, :only => [:index, :show, :edit, :update]"
    look_for = "\n    admin.resources #{setting}"
    logger.route "admin.resources #{setting}"
    unless options[:pretend]
      gsub_file 'config/routes.rb', /(Regexp.escape(look_for))/mi, ''
    end
  end
end