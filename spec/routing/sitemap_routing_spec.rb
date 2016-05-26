describe SitemapsController, type: :routing do
  describe 'routing' do
    it 'recognizes and generates #feed with sitemap type' do
      expect(get: '/sitemap.xml').to route_to(controller: 'sitemaps', action: 'show', format: 'xml')
    end

    it 'recognizes and generates #feed with sitemap type' do
      expect(get: '/news-sitemap.xml').to route_to(controller: 'sitemaps', action: 'show', news: true, format: 'xml')
    end
  end
end
