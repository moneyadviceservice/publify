feed.entry item, :id => "urn:uuid:#{item.guid}", :url => article_url(item.permalink) do |entry|
  entry.author do
    name = item.user.name rescue item.author
    email = item.user.email rescue nil
    entry.name name
    entry.email email if this_blog.link_to_author unless email.blank?
  end

  if item.is_a?(Note)
    entry.title truncate(item.html(:body).strip_html, length: 80, separator: ' ', omissions: '...'), "type"=>"html"
  else
    entry.title item.title, "type"=>"html"
  end

  if item.is_a?(Article)

    item.tags.each do |tag|
      entry.category "term" => tag.display_name, "scheme" => tag_path(tag.permalink)
    end

    item.resources.each do |resource|
      if resource.size > 0  # The Atom spec disallows files with size=0
        entry.tag! :link, "rel" => "enclosure",
              :type => resource.mime,
              :title => item.title,
              :href => resource.upload.thumb.url,
              :length => resource.size
      else
        entry.tag! :link, "rel" => "enclosure",
              :type => resource.mime,
              :title => item.title,
              :href => resource.upload.thumb.url
      end
    end
  end
  content_html = fetch_html_content_for_feeds(item, this_blog)
  entry.content content_html + item.get_rss_description, "type"=>"html"
end

