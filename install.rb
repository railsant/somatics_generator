require 'rubygems'

puts 'Copying files...'

public_path = File.join(Rails.root, 'public')
current_path = File.join(File.dirname(__FILE__)) 

javascripts_path = File.join(public_path, 'javascripts')
stylesheets_path = File.join(public_path, 'stylesheets')
images_path      = File.join(public_path, 'images', 'admin')
locales_path      = File.join(public_path, 'locales')

puts 'Copying javascript files...'
# copying JS
Dir.mkdir(javascripts_path) unless File.exists?(javascripts_path) 

plugin_javascripts_path = File.join(current_path, 'public', 'javascripts')

Dir.foreach(plugin_javascripts_path) do |javascript|
  src_javascript  = File.join(plugin_javascripts_path, javascript)

  if File.file?(src_javascript)
    dest_javascript = File.join(javascripts_path, javascript)
    FileUtils.cp_r(src_javascript, dest_javascript)
  end
end

puts 'Copying stylesheets files...'
# copying CSS
Dir.mkdir(stylesheets_path) unless File.exists?(stylesheets_path) 

plugin_stylesheets_path = File.join(current_path, 'public', 'stylesheets')

Dir.foreach(plugin_stylesheets_path) do |stylesheet|
  src_stylesheet  = File.join(plugin_stylesheets_path, stylesheet)

  if File.file?(src_stylesheet)
    dest_stylesheet = File.join(stylesheets_path, stylesheet)
    FileUtils.cp_r(src_stylesheet, dest_stylesheet)
  end
end

puts 'Copying images files...'
# copying images
Dir.mkdir(images_path) unless File.exists?(images_path) 

plugin_images_path = File.join(current_path, 'public', 'images')

Dir.foreach(plugin_images_path) do |image|
  src_image  = File.join(plugin_images_path, image)

  if File.file?(src_image)
    dest_image = File.join(images_path, image)
    FileUtils.cp_r(src_image, dest_image)
  end
end

puts 'Copying images files...'
# copying locales
Dir.mkdir(locales_path) unless File.exists?(locales_path) 

plugin_locales_path = File.join(current_path, 'locales')

Dir.foreach(plugin_locales_path) do |locale|
  src_locale  = File.join(plugin_locales_path, locale)

  if File.file?(src_locale)
    dest_locale = File.join(locales_path, locale)
    FileUtils.cp_r(src_locale, dest_locale)
  end
end


puts 'Done - Installation complete!'
