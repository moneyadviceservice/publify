# coding: utf-8
describe Admin::PagesController, type: :controller do
  let!(:blog) { create(:blog) }
  let!(:user) { create(:user, :as_admin) }

  before(:each) { request.session = { user: user.id } }

  describe '#index' do
    context 'without params' do
      before(:each) { get :index }
      it { expect(response).to be_success }
      it { expect(response).to render_template('index') }
      it { expect(assigns(:pages)).to_not be_nil }
    end

    context 'with page 1' do
      before(:each) { get :index, page: 1 }
      it { expect(response).to be_success }
      it { expect(response).to render_template('index') }
      it { expect(assigns(:pages)).to_not be_nil }
    end
  end

  describe '#new' do
    before(:each) { get :new }

    it { expect(response).to be_success }
    it { expect(response).to render_template('new') }
    it { expect(assigns(:page)).to_not be_nil }
    it { expect(assigns(:page).user).to eq(user) }
    it { expect(assigns(:page).text_filter.name).to eq('textile') }
    it { expect(assigns(:page).published).to be_truthy }
    end

  describe '#create' do
    def base_page(options = {})
      { title: 'posted via tests!',
        body: 'A good body',
        name: 'posted-via-tests',
        published: true }.merge(options)
    end

    context 'simple' do
      before(:each) do
        post :create, page: { name: 'new_page', title: 'New Page Title', body: 'Emphasis _mine_, arguments *strong*' }
      end

      it { expect(Page.first.name).to eq('new_page') }
      it { expect(response).to redirect_to(action: :index) }
      it { expect(flash[:success]).to eq(I18n.t('admin.pages.create.success')) }
    end

    it 'should create a published page with a redirect' do
      post(:create, 'page' => base_page)
      expect(assigns(:page).redirects.count).to eq(1)
    end

    it 'should create an unpublished page without a redirect' do
      post(:create, 'page' => base_page(state: :unpublished, published: false))
      expect(assigns(:page).redirects.count).to eq(0)
    end
  end

  describe '#edit' do
    let!(:page) { create(:page) }

    before(:each) { get :edit, id: page.id }
    it { expect(response).to be_success }
    it { expect(response).to render_template('edit') }
    it { expect(assigns(:page)).to eq(page) }
  end
  
  describe '#update' do
    let!(:page) { create(:page) }

    before(:each) do
      post :update, id: page.id, page: { name: 'markdown-page', title: 'Markdown Page', body: 'Adding a [link](http://www.publify.co/) here' }
    end

    it { expect(response).to redirect_to(action: :index) }
  end

  describe 'destroy' do
    let!(:page) { create(:page) }

    before(:each) { delete :destroy, id: page.id }

    it { expect(response).to redirect_to(action: :index) }
    it { expect(Page.count).to eq(0) }
  end
end
