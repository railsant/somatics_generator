excel_document(xml) do
  xml.Worksheet 'ss:Name' => '<%= plural_name.humanize %>' do
    xml.Table do
      # Header
      xml.Row do
        @headers.each do |header|
          xml.Cell { xml.Data header, 'ss:Type' => 'String' }
        end
      end

      # Rows
      unless @<%= plural_name %>.blank?
        for <%= singular_name %> in @<%= plural_name %>
          xml.Row do
            @fields.each do |f|
              xml.Cell { xml.Data <%= singular_name %>.send(f), 'ss:Type' => 'String' }
            end
          end
        end
      end

    end
  end
end