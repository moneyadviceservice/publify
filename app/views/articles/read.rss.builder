xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
xml.instruct! 'xml-stylesheet', :type=>"text/css", :href => url_for("/stylesheets/rss.css")

xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/",
        "xmlns:atom" => "http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.title feed_title
    xml.link this_blog.base_url
    xml.atom :link, :href => request.url, :rel => 'self', :type => 'application/rss+xml'
    xml.language this_blog.lang.gsub("_", "-").downcase
    xml.ttl "40"
    xml.description this_blog.blog_subtitle

    @feedback.each do |item|
      xml.item do
        xml.title item.feed_title
        xml.description html(item)
        xml.pubDate item.created_at.rfc822
        xml.guid "urn:uuid:#{item.guid}", "isPermaLink" => "false"
        xml.link item_url(item)
      end
    end
  end
end
