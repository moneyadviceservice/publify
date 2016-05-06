# coding: utf-8
describe ArticlesController, 'base', type: :controller do
  let!(:blog) { create(:blog) }
  let!(:campaign) { create(:campaign) }
  let!(:user) { create :user }

  describe 'index' do
    let!(:article) { create(:article) }

    before(:each) do
      allow(Campaign).to receive(:lead).and_return([campaign])
      allow(PopularArticle).to receive(:find).and_return([])

      get :index 
    end

    it { expect(response).to render_template(:index) }
    it { expect(assigns[:articles]).to_not be_empty }
  end

  describe '#search action' do
    before(:each) do
      create(:article, body: "in markdown format\n\n * we\n * use\n [ok](http://blog.ok.com) to define a link", text_filter: create(:markdown))
      create(:article, body: 'xyz')
    end

    describe 'a valid search' do
      before(:each) { get :search, q: 'a' }

      it { expect(response).to render_template(:search) }
      it { expect(assigns[:articles]).to_not be_nil }
    end

    it 'search with empty result' do
      get 'search', q: 'abcdefghijklmnopqrstuvwxyz'
      expect(response).to render_template('articles/search', layout: true)
    end
  end

  describe '#archives' do
    it 'works' do
      3.times { create(:article) }
      get 'archives'
      expect(response).to render_template(:archives)
      expect(assigns[:articles]).not_to be_nil
      expect(assigns[:articles]).not_to be_empty
    end
  end
end

describe ArticlesController, 'feeds', type: :controller do
  let!(:blog) { create(:blog) }

  let!(:article1) { create(:article, created_at: Time.now - 1.day) }
  let!(:article2) { create(:article, created_at: '2004-04-01 12:00:00', published_at: '2004-04-01 12:00:00', updated_at: '2004-04-01 12:00:00') }

  specify '/articles.atom => an atom feed' do
    get 'index', format: 'atom'
    expect(response).to be_success
    expect(response).to render_template('articles/index', layout: false)
    expect(assigns(:articles)).to eq([article1, article2])
  end

  specify '/articles.rss => an RSS 2.0 feed' do
    get 'index', format: 'rss'
    expect(response).to be_success
    expect(response).to render_template('articles/index', layout: false)
    expect(assigns(:articles)).to eq([article1, article2])
  end
end

describe ArticlesController, 'the index', type: :controller do
  let!(:blog) { create(:blog) }

  before(:each) do
    create(:user, login: 'henri', profile: create(:profile_admin, label: Profile::ADMIN))
    create(:article)
  end

  it 'should ignore the HTTP Accept: header' do
    request.env['HTTP_ACCEPT'] = 'application/atom+xml'
    get 'index'
    expect(response).to render_template('index')
  end
end

describe ArticlesController, 'previewing', type: :controller do
  let!(:blog) { create(:blog) }

  describe 'with non logged user' do
    before :each do
      @request.session = {}
      get :preview, id: create(:article).id
    end

    it 'should redirect to login' do
      expect(response).to redirect_to(login_path)
    end
  end

  describe 'with logged user' do
    let(:admin) { create(:user, :as_admin) }
    let(:article) { create(:article, user: admin) }

    before(:each) { @request.session = { user: admin.id } }

    it 'should assigns article define with id' do
      get :preview, id: article.id
      expect(assigns[:article]).to eq(article)
    end

    it 'should assigns last article with id like parent_id' do
      draft = create(:article, parent_id: article.id)
      get :preview, id: article.id
      expect(assigns[:article]).to eq(draft)
    end
  end
end

describe ArticlesController, 'redirecting', type: :controller do

  describe 'with explicit redirects' do
    it 'should redirect from known URL' do
      build_stubbed(:blog)
      create(:user)
      create(:redirect)
      get :show, from: 'foo/bar'
      assert_response 301
      expect(response).to redirect_to('http://test.host/someplace/else')
    end

    it 'should not redirect from unknown URL' do
      build_stubbed(:blog)
      create(:user)
      create(:redirect)
      get :show, from: 'something/that/isnt/there'
      assert_response 404
    end

    # FIXME: Due to the changes in Rails 3 (no relative_url_root), this
    # does not work anymore when the accessed URL does not match the blog's
    # base_url at least partly. Do we still want to allow acces to the blog
    # through non-standard URLs? What was the original purpose of these
    # redirects?
    describe 'and non-empty relative_url_root' do
      before do
        build_stubbed(:blog, base_url: 'http://test.host/blog')
        create(:user)
      end

      it 'should redirect' do
        create(:redirect, from_path: 'foo/bar', to_path: '/someplace/else')
        get :show, from: 'foo/bar'
        assert_response 301
        expect(response).to redirect_to('http://test.host/blog/someplace/else')
      end

      it 'should redirect if to_path includes relative_url_root' do
        create(:redirect, from_path: 'bar/foo', to_path: '/blog/someplace/else')
        get :show, from: 'bar/foo'
        assert_response 301
        expect(response).to redirect_to('http://test.host/blog/someplace/else')
      end

      it 'should ignore the blog base_url if the to_path is a full uri' do
        create(:redirect, from_path: 'foo', to_path: 'http://some.where/else')
        get :show, from: 'foo'
        assert_response 301
        expect(response).to redirect_to('http://some.where/else')
      end
    end
  end

  it 'should get good article with utf8 slug' do
    build_stubbed(:blog)
    utf8article = create(:utf8article, permalink: 'ルビー')
    get :show, from: 'ルビー'
    expect(assigns(:article)).to eq(utf8article)
  end

  describe 'with at the permalink url' do
    let!(:blog) { create(:blog) }
    let!(:admin) { create(:user, :as_admin) }

    before(:each) do
      @request.session = { user: admin.id }
    end

    context 'with an article' do
      let!(:article) { create(:article, permalink: 'second-blog-article', published_at: '2004-04-01 02:00:00', updated_at: '2004-04-01 02:00:00', created_at: '2004-04-01 02:00:00') }

      context 'try redirect to an unknow location' do
        before(:each) { get :show, from: "#{article.permalink}/foo/bar" }
        it { expect(response.code).to eq('404') }
      end
    end

    describe 'accessing an article' do
      let!(:article) { create(:article, permalink: 'second-blog-article', published_at: '2004-04-01 02:00:00', updated_at: '2004-04-01 02:00:00', created_at: '2004-04-01 02:00:00') }
      before(:each) do
        get :show, from: "#{article.permalink}"
      end

      it 'should render template read to article' do
        expect(response).to render_template('articles/read')
      end

      it 'should assign article1 to @article' do
        expect(assigns(:article)).to eq(article)
      end
    end

    describe 'rendering as atom feed' do
      let!(:article) { create(:article, permalink: 'second-blog-article', published_at: '2004-04-01 02:00:00', updated_at: '2004-04-01 02:00:00', created_at: '2004-04-01 02:00:00') }

      before(:each) do
        get :show, from: "#{article.permalink}", format: "atom"
      end

      it 'should render feedback atom feed' do
        expect(response).to render_template('articles/read', layout: false)
      end
    end

    describe 'rendering as rss feed' do
      let!(:article) { create(:article, permalink: 'second-blog-article', published_at: '2004-04-01 02:00:00', updated_at: '2004-04-01 02:00:00', created_at: '2004-04-01 02:00:00') }

      before(:each) do
        get :show, from: "#{article.permalink}", format: "rss"
      end

      it 'should render rss20 partial' do
        expect(response).to render_template('articles/read', layout: false)
      end
    end
  end
end

describe ArticlesController, 'assigned keywords', type: :controller do
  before(:each) { create :user }

  context 'with default blog' do
    let!(:blog) { create(:blog) }

    it 'index without option and no blog keywords should not have meta keywords' do
      get 'index'
      expect(assigns(:keywords)).to eq('')
    end
  end

  context "with blog meta keywords to 'publify, is, amazing'" do
    let!(:blog) { create(:blog, meta_keywords: 'publify, is, amazing') }

    it 'index without option but with blog keywords should have meta keywords' do
      get 'index'
      expect(assigns(:keywords)).to eq('publify, is, amazing')
    end
  end
end
