describe "/sitemap.xml" do
  before :each do
    Blog.create!(base_url: "http://localhost:3000")
    TextFilter.create!(name: 'none', description: 'None', markup: 'none', filters: [], params: {})
  end

  context 'when there are articles' do
    let!(:article) { Article.create!(title: 'my article', keywords: "General", published_at: Time.now) }

    it 'returns article location' do
      get "/sitemap.xml"
      expect(response.body).to include(article.permalink)
    end
  end

  context 'when there are news articles' do
    let!(:article) { Article.create!(title: 'my news article', keywords: "News,General", published_at: Time.now) }

    it 'does not include news articles' do
      get "/sitemap.xml"
      expect(response.body).to_not include(article.permalink)
    end
  end
end
