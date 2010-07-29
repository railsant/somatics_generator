class AdminAttributesGenerator < Rails::Generator::AdminScaffoldGenerator
  def initialize(runtime_args, runtime_options = {})
    super(runtime_args, runtime_options)
  end

  def manifest
    record do |m|
      m.directory(File.join('app/views', controller_class_path, controller_file_name))
      m.update_show_partial
      m.update_form_partial
      m.update_list_partial
      
      %w( zh-TW ).each do |locale|
        m.update_locales(locale)
      end
      
      migration_name = attributes.collect(&:name).join('_and_')
      m.migration_template 'migration:migration.rb', "db/migrate", {
        :assigns => {
          :migration_action => 'add',
          :class_name => "add_#{migration_name}_to_#{table_name}",
          :table_name => table_name,
          :attributes => attributes
        },
        :migration_file_name => "add_#{migration_name}_to_#{table_name}"
      }
    end
  end

end

class Rails::Generator::Commands::Create
  require 'net/http'
  require 'uri'
  require 'json'
  class GoogleTranslate
    def self.t(text)
      uri = URI.parse('http://ajax.googleapis.com/ajax/services/language/translate')
      JSON.parse(Net::HTTP.post_form(uri, {"q" => text, "langpair" => "en|zh-TW", "v" => '1.0'}).body)['responseData']['translatedText'] rescue text.humanize
    end
  end
  
  def update_show_partial
    look_for = "</tbody>\n</table>"
    gsub_file File.join('app/views/', controller_class_path, controller_file_name, '_show.html.erb'), /(#{Regexp.escape(look_for)})/mi do |match|
      result = attributes.inject('') do |str, attribute|
        str + "  <tr>\n    <td><b>#{attribute.name.humanize}</b></td>\n    <td><%=h #{singular_name}.#{attribute.name} %></td>\n  </tr>\n"
      end
      result + look_for
    end
    logger.update File.join('app/views/', controller_class_path, controller_file_name, '_show.html.erb')
  end
  
  def update_form_partial
    look_for = "</tbody>\n</table>"
    gsub_file File.join('app/views/', controller_class_path, controller_file_name, '_form.html.erb'), /(#{Regexp.escape(look_for)})/mi do |match|
      result = attributes.inject('') do |str, attribute|
        str + "  <tr>\n    <td><b><%= #{class_name}.human_attribute_name(:#{attribute.name}) %></b></td>\n    <td><%= f.#{attribute.field_type} :#{attribute.name} %></td>\n  </tr>\n"
      end
      result + look_for
    end
    logger.update File.join('app/views/', controller_class_path, controller_file_name, '_form.html.erb')
  end
  
  def update_list_partial
    look_for = "		  <!-- More Sort Link Helper-->"
    gsub_file File.join('app/views/', controller_class_path, controller_file_name, '_list.html.erb'), /(#{Regexp.escape(look_for)})/mi do |match|
      result = attributes.inject('') do |str, attribute|
        str + "      <th title=\"Sort by &quot;#{attribute.name.humanize}&quot;\"><%= sort_link_helper '#{attribute.name.humanize}', '#{attribute.name}' %></th>\n"
      end
      result + look_for
    end
    look_for = "      <!-- More Fields -->"
    gsub_file File.join('app/views/', controller_class_path, controller_file_name, '_list.html.erb'), /(#{Regexp.escape(look_for)})/mi do |match|
      result = attributes.inject('') do |str, attribute|
        str + "      <td onclick=\"link_to(<%= \"'\#{admin_#{singular_name}_path(#{singular_name})}'\" %>);\" class=\"#{attribute.name}\"><%=h #{singular_name}.#{attribute.name} %></td>\n"
      end
      result + look_for
    end
    logger.update File.join('app/views/', controller_class_path, controller_file_name, '_list.html.erb')
  end
  
  def update_locales(locale)
    gsub_file File.join('config/locales', "#{controller_file_name}_#{locale}.yml"), /\z/mi do |match|
      attributes.inject('') do |str, attribute|
        str + "        #{attribute.name}: #{GoogleTranslate.t attribute.name}\n"
      end
    end
    logger.update File.join('config/locales', "#{controller_file_name}_#{locale}.yml")
  end
end

class Rails::Generator::Commands::Destroy
  def update_show_partial
    look_for = attributes.inject('') do |str, attribute|
      str + "  <tr>\n    <td><b>#{attribute.name.humanize}</b></td>\n    <td><%=h #{singular_name}.#{attribute.name} %></td>\n  </tr>\n"
    end
    gsub_file File.join('app/views/', controller_class_path, controller_file_name, '_show.html.erb'), /(#{Regexp.escape(look_for)})/mi, ''
    logger.revert File.join('app/views/', controller_class_path, controller_file_name, '_show.html.erb')
  end

  def update_form_partial
    look_for = attributes.inject('') do |str, attribute|
      str + "  <tr>\n    <td><b><%= #{class_name}.human_attribute_name(:#{attribute.name}) %></b></td>\n    <td><%= f.#{attribute.field_type} :#{attribute.name} %></td>\n  </tr>\n"
    end
    gsub_file File.join('app/views/', controller_class_path, controller_file_name, '_form.html.erb'), /(#{Regexp.escape(look_for)})/mi, ''
    logger.revert File.join('app/views/', controller_class_path, controller_file_name, '_form.html.erb')
  end

  def update_list_partial
    look_for = attributes.inject('') do |str, attribute|
      str + "      <th title=\"Sort by &quot;#{attribute.name.humanize}&quot;\"><%= sort_link_helper '#{attribute.name.humanize}', '#{attribute.name}' %></th>\n"
    end
    gsub_file File.join('app/views/', controller_class_path, controller_file_name, '_list.html.erb'), /(#{Regexp.escape(look_for)})/mi, ''
    look_for = attributes.inject('') do |str, attribute|
      str + "      <td onclick=\"link_to(<%= \"'\#{admin_#{singular_name}_path(#{singular_name})}'\" %>);\" class=\"#{attribute.name}\"><%=h #{singular_name}.#{attribute.name} %></td>\n"
    end
    gsub_file File.join('app/views/', controller_class_path, controller_file_name, '_list.html.erb'), /(#{Regexp.escape(look_for)})/mi, ''
    logger.revert File.join('app/views/', controller_class_path, controller_file_name, '_list.html.erb')
  end
  
  def update_locales(locale)
    look_for = attributes.inject('') do |str, attribute|
      str + "        #{attribute.name}: #{GoogleTranslate.t attribute.name}\n"
    end
    gsub_file File.join('config/locales', "#{controller_file_name}_#{locale}.yml"), /(#{Regexp.escape(look_for)})/mi, ''
    logger.revert File.join('config/locales', "#{controller_file_name}_#{locale}.yml")
  end
end