describe CommentsController, type: :controller do
  let!(:blog) { create(:blog) }

  describe 'create' do
    describe 'Basic comment creation' do
      let(:article) { create(:article) }
      let(:comment) { { body: 'content', author: 'bob', email: 'bob@home', url: 'http://bobs.home/' } }

      before { post :create, comment: comment, article_id: article.id }

      it { expect(assigns[:comment]).to eq(Comment.find_by_author_and_body_and_article_id('bob', 'content', article.id)) }
      it { expect(assigns[:article]).to eq(article) }
      it { expect(article.comments.size).to eq(1) }
      it { expect(article.comments.last.author).to eq('bob') }
      it { expect(session['author']).to eq('bob') }
      it { expect(session['email']).to eq('bob@home') }
    end

    it 'should redirect to the article' do
      article = create(:article, created_at: '2005-01-01 02:00:00')
      post :create, comment: { body: 'content', author: 'bob', email: 'bob@foo.com' }, article_id: article.id
      expect(response).to redirect_to("http://test.host/#{article.permalink}#comment-#{article.comments.last.id}")
    end
  end

  describe 'index' do
    context 'without format' do
      it 'throws a 406' do
        expect { get :index }.to raise_error(ActionController::UnknownFormat)
      end
    end

    context 'with atom format' do
      context 'without article' do
        let!(:some) { create(:comment) }
        let!(:items) { create(:comment) }

        before(:each) { get 'index', format: 'atom' }

        it { expect(response).to be_success }
        it { expect(assigns(:comments)).to eq([some, items]) }
        it { expect(response).to render_template('comments/index') }
      end

      context 'with an article' do
        let!(:article) { create(:article) }
        before(:each) { get :index, format: 'atom', article_id: article.id }
        it { expect(response).to be_success }
        it { expect(response).to render_template('comments/index') }
      end
    end

    context 'with rss format' do
      context 'without article' do
        let!(:some) { create(:comment, title: 'some') }
        let!(:items) { create(:comment, title: 'items') }

        before { get 'index', format: 'rss' }
        it { expect(response).to be_success }
        it { expect(assigns(:comments)).to eq([some, items]) }
        it { expect(response).to render_template('comments/index') }
      end

      context 'with article' do
        let!(:article) { create(:article) }
        before(:each) { get :index, format: 'rss', article_id: article.id }

        it { expect(response).to be_success }
        it { expect(response).to render_template('comments/index') }
      end
    end
  end
end
