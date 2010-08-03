xml.instruct!
xml.<%= plural_name %> do
  @<%= plural_name %>.each do |<%= singular_name %>|
    xml.<%= singular_name %> do
      @fields.each do |f|
        xml.tag! f, <%= singular_name %>.send(f)
      end
    end
  end
end