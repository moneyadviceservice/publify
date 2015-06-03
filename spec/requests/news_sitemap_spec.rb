describe "/news-sitemap.xml" do
  before :each do
    Blog.create!(base_url: "http://localhost:3000")
    TextFilter.create!(name: 'none', description: 'None', markup: 'none', filters: [], params: {})
  end

  context 'when there are news articles' do
    let!(:article) { Article.create!(title: 'my news article', keywords: "News,General", published_at: Time.now) }

    it 'returns the news article' do
      get "/news-sitemap.xml"
      expect(response.body).to include(article.permalink)
      expect(response.body).to include(article.title)
    end
  end

  context 'when articles are not tagged as news' do
    let!(:article) { Article.create!(title: 'my news article', keywords: "General", published_at: Time.now) }

    it 'is not included' do
      get "/news-sitemap.xml"
      expect(response.body).to_not include(article.permalink)
    end
  end

  context 'when there are news articles published over 48 hours ago' do
    let!(:article) { Article.create!(title: 'my news article', keywords: "News,General", published_at: 50.hours.ago) }

    it 'does not return the news article' do
      get "/news-sitemap.xml"
      expect(response.body).to_not include(article.permalink)
    end
  end
end
