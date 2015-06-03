describe "/news" do
  before :each do
    Blog.create!(base_url: "http://localhost:3000")
    TextFilter.create!(name: 'none', description: 'None', markup: 'none', filters: [], params: {})
  end

  context 'when there are news articles' do
    it 'returns news articles' do
      Article.create!(title: 'my news article', keywords: "News,General", published_at: Time.now)
      get "/news"
      expect(response.body).to include("my news article")
    end
  end

  context 'when there are no news articles' do
    it 'redirects to root path' do
      get "/news"
      expect(response).to redirect_to("http://localhost:3000")
    end
  end
end
