describe Admin::SettingsController, type: :controller do

  before(:each) do
    create(:blog)
    alice = create(:user, :as_admin, login: 'alice')
    request.session = { user: alice.id }
  end

  describe 'general action' do
    before(:each) { get :general }
    it { expect(response).to render_template('general') }
  end

  describe 'seo action' do
    before(:each) { get :seo }
    it { expect(response).to render_template('seo') }
  end

  describe 'write action' do
    before(:each) { get :write }
    it { expect(response).to render_template('write') }
  end

  describe 'display action' do
    before(:each) { get :display }
    it { expect(response).to render_template('display') }
  end

  describe 'feedback action' do
    before(:each) { get :feedback }
    it { expect(response).to render_template('feedback') }
  end

  describe 'update action' do
    it 'should success' do
      referrer = 'http://foo.bar'
      request.env["HTTP_REFERER"] = referrer
      post :update, { 'authenticity_token' => 'f9ed457901b96c65e99ecb73991b694bd6e7c56b',
                     'setting' => { 'unindex_categories' => '1',
                                 'meta_keywords' => 'my keywords',
                                 'meta_description' => '',
                                 'rss_description' => '1',
                                 'robots' => "User-agent: *\r\nDisallow: /admin/\r\nDisallow: /page/\r\nDisallow: /cgi-bin \r\nUser-agent: Googlebot-Image\r\nAllow: /*",
                                 'index_tags' => '1' } }

      expect(response).to redirect_to(referrer)
    end

  end
end
