atom_feed do |feed|
  render "shared/atom_header", {:feed => feed, :items => @feedback}

  @feedback.each do |item|
    feed.entry item, :id => "urn:uuid:#{item.guid}", :url => item_url(item) do |entry|
      entry.author do
        entry.name item.author
        entry.uri item.url
      end
      entry.title item.feed_title, "type"=>"html"
      entry.content html(item), "type"=>"html"
    end
  end
end
