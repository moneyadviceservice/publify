describe Admin::ResourcesController, type: :controller do
  before do
    FactoryBot.create(:blog)
    #TODO Delete after removing fixtures
    Profile.delete_all
    henri = FactoryBot.create(:user, login: 'henri', profile: FactoryBot.create(:profile_admin, label: Profile::ADMIN))
    @request.session = { user: henri.id }
  end

  describe 'test_index' do
    before(:each) do
      get :index
    end

    it 'should render index template' do
      assert_response :success
      assert_template 'index'
      expect(assigns(:resources)).not_to be_nil
    end
  end

  describe '#remove' do
    before(:each) do
      @res_id = FactoryBot.create(:resource).id
      get :remove, id: @res_id
    end

    it 'should render template destroy' do
      assert_response :success
      assert_template 'remove'
    end

    it 'should have a valid file' do
      expect(Resource.find(@res_id)).not_to be_nil
      expect(assigns(:resource)).not_to be_nil
    end
  end

  it '#destroy' do
    res_id = FactoryBot.create(:resource).id

    delete :destroy, id: res_id
    expect(response).to redirect_to(admin_resources_path)
  end
end
