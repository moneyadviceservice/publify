xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
xml.urlset "xmlns"=>"http://www.sitemaps.org/schemas/sitemap/0.9", "xmlns:news" => "http://www.google.com/schemas/sitemap-news/0.9" do
  @items.each do |item|
    render "googlesitemap_item_news", {:item => item, :xm => xml}
  end
end
