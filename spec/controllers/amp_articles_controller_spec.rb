# coding: utf-8
describe AmpArticlesController, 'base', type: :controller do
  let!(:blog) { create(:blog) }

  describe '#show' do
    let!(:article) { create(:article, permalink: 'second-blog-article', published_at: '2004-04-01 02:00:00', updated_at: '2004-04-01 02:00:00', created_at: '2004-04-01 02:00:00') }
    before(:each) do
      get :show, from: "#{article.permalink}"
    end

    it 'should render template read to article' do
      expect(response).to render_template('articles/amp/show')
    end

    it 'should assign article1 to @article' do
      expect(assigns(:article)).to eq(article)
    end
  end
end
