describe NewsController do
  before :each do
    create(:blog)
  end

  context 'when requesting a news article' do
    let(:article) { create(:article, keywords: "News") }

    it 'loads the news article' do
      get :show_article, id: article.permalink
      expect(assigns(:article)).to eql(article)
    end
  end

  context 'when requesting a non news article' do
    let(:article) { create(:article) }

    it 'does not load the article' do
      expect{ get :show_article, id: article.permalink }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
