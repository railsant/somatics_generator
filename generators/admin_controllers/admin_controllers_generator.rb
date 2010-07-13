class AdminControllersGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions('Admin::HomeController', 'Admin::AdminController', 'AdminHelper')
      
      # Controller, helper, views, test and stylesheets directories.
      m.directory File.join('app/controllers/admin')
      m.directory File.join('app/helpers/admin')
      m.directory File.join('app/views/layouts')
      m.directory File.join('app/views/admin/shared')
      m.directory File.join('app/views/admin/home')
      m.directory File.join('test/functional/admin')
      m.directory File.join('public/stylesheets')
      m.directory File.join('public/javascripts')
      
      # Controller      
      m.template 'controller_admin.rb', File.join('app/controllers/admin', 'admin_controller.rb')
      m.template 'controller_home.rb', File.join('app/controllers/admin', 'home_controller.rb')
      
      # Helpers
      m.template 'helper_admin.rb', File.join('app/helpers/admin', 'admin_helper.rb')
      
      # Home Views
      m.template 'view_index.html.erb', File.join('app/views/admin', 'home', 'index.html.erb')
      
      # Layouts
      m.template 'layout_admin.html.erb', File.join('app/views/layouts', "admin.html.erb")
      m.template 'partial_menu.html.erb', File.join('app/views/admin/shared', "_menu.html.erb")
      
      # Stylesheets and Javascripts.
      m.template_without_destroy 'css_admin.css', 'public/stylesheets/admin.css'
      m.template_without_destroy 'css_jstoolbar.css', 'public/stylesheets/jstoolbar.css'
      m.template_without_destroy 'css_context_menu.css', 'public/stylesheets/context_menu.css'
      m.template_without_destroy 'css_csshover.htc', 'public/stylesheets/csshover.htc'      
      m.template_without_destroy 'js_context_menu.js', 'public/javascripts/context_menu.js'
      m.template_without_destroy 'js_select_list_move.js', 'public/javascripts/select_list_move.js'
      
      # Images
      # m.file 'vendor/somatics_generator/images/*', 'public/images', :collision => :skip
      
      # Routing
      m.admin_route_root :controller => 'home', :action => 'index'
      m.admin_route_name 'home', '/admin/index', {:controller => 'home', :action => 'index'}
    end
  end
  
  protected
  
  def banner
    "Usage: #{$0} admin_controllers"
  end
end

class Rails::Generator::Commands::Create
  def admin_route_root(options = {})
    options[:controller] ||= 'home'
    options[:action] ||= 'index'
    sentinel = 'ActionController::Routing::Routes.draw do |map|'
    logger.route "admin.root :controller => '#{options[:controller]}', :action => '#{options[:action]}'"
    unless options[:pretend]
      gsub_file 'config/routes.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
        "#{match}\n  map.namespace(:admin) do |admin|\n    admin.root :controller => '#{options[:controller]}', :action => '#{options[:action]}'\n  end\n"
      end
    end
  end
  
  def admin_route_resource(*resources)
    resource_list = resources.map { |r| r.to_sym.inspect }.join(', ')
    sentinel = 'map.namespace(:admin) do |admin|'

    logger.route "admin.resource #{resource_list}"
    unless options[:pretend]
      gsub_file 'config/routes.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
        "#{match}\n    admin.resource #{resource_list}"
      end
    end
  end
  
  def admin_route_name(name, path, route_options = {})
    sentinel = 'map.namespace(:admin) do |admin|'
    
    logger.route "admin.#{name} '#{path}', :controller => '#{route_options[:controller]}', :action => '#{route_options[:action]}'"
    unless options[:pretend]
      gsub_file 'config/routes.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
        "#{match}\n    admin.#{name} '#{path}', :controller => '#{route_options[:controller]}', :action => '#{route_options[:action]}'"
      end
    end
  end
  
  def header_menu(resource)
    gsub_file File.join('app/views/layouts', controller_class_path, "_menu.html.erb"), /\z/mi do |match|
      "<li><%= link_to '#{resource.humanize}', '/admin/#{resource}', :class => (match_controller?('#{controller_file_name}'))  ? 'selected' : ''%></li>\n"
    end
  end
  
  alias_method  :template_without_destroy,  :template
end

class Rails::Generator::Commands::Destroy
  def admin_route_root(options = {})
    options[:controller] ||= 'home'
    options[:action] ||= 'index'
    look_for = "\n  map.namespace(:admin) do |admin|\n    admin.root :controller => '#{options[:controller]}', :action => '#{options[:action]}'\n  end\n"
    logger.route "admin.root :controller => '#{options[:controller]}', :action => '#{options[:action]}"
    unless options[:pretend]
      gsub_file 'config/routes.rb', /(#{Regexp.escape(look_for)})/mi, ''
    end
  end
  
  def admin_route_resource(*resources)
    resource_list = resources.map { |r| r.to_sym.inspect }.join(', ')
    look_for = "\n    admin.resource #{resource_list}"
    logger.route "admin.resource #{resource_list}"
    unless options[:pretend]
      gsub_file 'config/routes.rb', /(#{look_for})/mi, ''
    end
  end
  
  def admin_route_name(name, path, route_options = {})
    look_for = "\n    admin.#{name} '#{path}', :controller => '#{route_options[:controller]}', :action => '#{route_options[:action]}'"
    logger.route "admin.#{name} '#{path}',     :controller => '#{route_options[:controller]}', :action => '#{route_options[:action]}'"
    unless options[:pretend]
      gsub_file    'config/routes.rb', /(#{look_for})/mi, ''
    end
  end
  
  def header_menu(resource)
    # resource_list = resources.map { |r| r.to_sym.inspect }.join(', ')
    look_for = "<li><%= link_to '#{resource.humanize}', '/admin/#{resource}', :class => (match_controller?('#{controller_file_name}'))  ? 'selected' : ''%></li>\n"
    gsub_file File.join('app/views/layouts', controller_class_path, "_menu.html.erb"), /(#{Regexp.escape(look_for)})/mi, ''
  end
  
  def template_without_destroy(relative_source, relative_destination, file_options = {})
  end
end

class Rails::Generator::Commands::List
  def admin_route_root(options = {})
    options[:controller] ||= 'home'
    options[:action] ||= 'index'
    logger.route "admin.root :controller => '#{controller}', :action => '#{action}"
  end
  
  def admin_route_resource(*resources)
    resource_list = resources.map { |r| r.to_sym.inspect }.join(', ')
    logger.route "map.resource #{resource_list}"
  end
  
  def admin_route_name(name, path, options = {})
    logger.route "map.#{name} '#{path}', :controller => '{options[:controller]}', :action => '#{options[:action]}'"
  end
end