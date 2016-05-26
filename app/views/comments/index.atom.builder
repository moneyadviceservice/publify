atom_feed do |feed|
  render "shared/atom_header", {feed: feed, items: @comments}

  @comments.each do |comment|
    feed.entry comment, :id => "urn:uuid:#{comment.guid}", :url => item_url(comment) do |entry|
      entry.author do
        entry.name comment.author
        entry.uri comment.url
      end
      entry.title comment.feed_title, "type"=>"html"
      entry.content html(comment), "type"=>"html"
    end
  end
end
