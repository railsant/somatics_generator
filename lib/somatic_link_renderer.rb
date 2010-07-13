class SomaticLinkRenderer < WillPaginate::LinkRenderer
  
  def to_html
    links = @options[:page_links] ? windowed_links : []
    # previous/next buttons
    links.unshift page_link_or_span(@collection.previous_page, 'disabled prev_page', @options[:previous_label])
    links.push    page_link_or_span(@collection.next_page,     'disabled next_page', @options[:next_label])
    
    html = links.join(@options[:separator])
    html += "( #{@collection.offset+1}-#{@collection.offset + @collection.per_page}/#{@collection.total_entries} )"
    @options[:container] ? @template.content_tag(:p, html, html_attributes) : html
  end
  
protected

  def page_link(page, text, attributes = {})
    # @template.content_tag(:li, @template.link_to(text, url_for(page)), attributes)
    # @template.link_to(text, url_for(page), attributes)
    @template.link_to_remote(text,{
        :url => {:action => 'list', :params => @template.params.merge({:page => page})},
        :update => 'content',
        :method => :get
    },attributes.merge({
      :href => url_for(page)
    })
    )
  end

  def page_span(page, text, attributes = {})
    # @template.content_tag(:li, text, attributes)
    @template.content_tag(:span, text, attributes)
  end

end