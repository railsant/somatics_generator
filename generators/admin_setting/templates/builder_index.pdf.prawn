pdf.header pdf.margin_box.top_left do 
  # pdf.image "#{RAILS_ROOT}/public/images/logo.png", :fit => [60,24]
  pdf.text "<%= plural_name.humanize %>", :size => 16, :align => :center   
end

fields = params[:fields]# - [""]

entries = @<%= plural_name %>.collect do |<%= singular_name %>| 
  fields.collect do |f| 
    <%= singular_name %>.send(f)
  end
end

x_pos = ((pdf.bounds.width / 2) - 150) 
y_pos = ((pdf.bounds.height / 2) + 300) 
pdf.bounding_box([x_pos, y_pos], :width => 300, :height => 450) do 
  pdf.table entries, :border_style => :grid,
    :row_colors => ["FFFFFF","DDDDDD"],
    :headers => @headers,
    :position => :center,
    :font_size => 9
end

pdf.number_pages "<page>/<total>", [pdf.bounds.right - 50, 0]

