# Methods added to this helper will be available to all templates in the application.
module Admin::AdminHelper
  def content_for(name, content = nil, &block)
    @has_content ||= {}
    @has_content[name] = true
    super(name, content, &block)
  end
  
  def has_content?(name)
    (@has_content && @has_content[name]) || false
  end

  def match_controller?(name)
    controller.controller_name == name
  end

  def match_action?(name)
    controller.action_name == name
  end

  def sort_asc_desc_helper(param)
    result = image_tag('sort_asc.png') if params[:sort] == param
    result = image_tag('sort_desc.png') if params[:sort] == param + "_reverse"
    return result || ''
  end

  def sort_link_helper(text, param)
    key = param
    key += "_reverse" if params[:sort] == param
    options = {
      :url => {:action => 'list', :params => params.merge({:sort => key, :page => nil})},
      :update => 'content',
	    :method => :get
    }
    html_options = {
      :title => "Sort by this field",
      :href => url_for(:action => 'list', :params => params.merge({:sort => key, :page => nil}))
    }
    link_to_remote(text + sort_asc_desc_helper(param), options, html_options)
  end

  def operators_for_select(filter_type)
    Query.operators_by_filter_type[filter_type].collect {|o| [(Query.operators[o].to_s.humanize), o]}
  end
  
  def excel_document(xml, &block)
    xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8" 
    xml.Workbook({
      'xmlns'      => "urn:schemas-microsoft-com:office:spreadsheet", 
      'xmlns:o'    => "urn:schemas-microsoft-com:office:office",
      'xmlns:x'    => "urn:schemas-microsoft-com:office:excel",    
      'xmlns:html' => "http://www.w3.org/TR/REC-html40",
      'xmlns:ss'   => "urn:schemas-microsoft-com:office:spreadsheet" 
    }) do
      xml.Styles do
        xml.Style 'ss:ID' => 'Default', 'ss:Name' => 'Normal' do
          xml.Alignment 'ss:Vertical' => 'Bottom'
          xml.Borders
          xml.Font 'ss:FontName' => 'Arial'
          xml.Interior
          xml.NumberFormat
          xml.Protection
        end
      end
      yield block
    end
  end
end
