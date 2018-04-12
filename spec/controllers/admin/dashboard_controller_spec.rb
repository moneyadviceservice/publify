describe Admin::DashboardController, type: :controller do
  describe 'test publisher profile' do
    before do
      @blog ||= FactoryBot.create(:blog)
      #TODO Delete after removing fixtures
      Profile.delete_all
      @rene = FactoryBot.create(:user, login: 'rene', profile: FactoryBot.create(:profile_publisher, label: Profile::PUBLISHER))
      request.session = { user: @rene.id }
      get :index
    end

    it 'should render the index template' do
      expect(response.body).to render_template('index')
    end
  end

end
