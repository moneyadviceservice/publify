xm.item do
  if item.is_a?(Note)
    xm.title truncate(item.html(:body).strip_html, length: 80, separator: ' ', omissions: '...')
  else
    xm.title item.title
  end
  content_html = fetch_html_content_for_feeds(item, this_blog)
  xm.description content_html + item.get_rss_description
  xm.pubDate item.published_at.rfc822
  xm.guid "urn:uuid:#{item.guid}", "isPermaLink" => "false"

  xm.author "blog@moneyadviceservice.org.uk (#{item.user.name})"

  if item.is_a?(Article)
    xm.comments(item_url(item, anchor: :comments))

    for tag in item.tags
      xm.category tag.display_name
    end

    if (image = item.hero_image) && (image.file)
      if (image.versions[:resized].file.exists?)
        file = image.versions[:resized].file
        xm.enclosure(
          url: image.url(:resized),
          length: file.size,
          type: file.content_type)
      end
    end
  end

  xm.link item_url(item.permalink)
end
