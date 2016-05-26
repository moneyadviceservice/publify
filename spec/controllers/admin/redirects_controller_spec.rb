describe Admin::RedirectsController, type: :controller do
  before do
    FactoryGirl.create(:blog)
    #TODO Delete after removing fixtures
    Profile.delete_all
    henri = FactoryGirl.create(:user, login: 'henri', profile: FactoryGirl.create(:profile_admin, label: Profile::ADMIN))
    request.session = { user: henri.id }
  end

  describe '#index' do
    before(:each) do
      get :index
    end

    it 'should display index with redirects' do
      assert_response :redirect, action: 'new'
    end
  end

  describe '#create' do
    it 'redirects after creation' do
      post :create, 'redirect' => { from_path: 'some/place', to_path: 'somewhere/else' }
      assert_response :redirect, action: 'index'
    end

    it 'creates a redirect' do
      expect do
        post :create, 'redirect' => { from_path: '', to_path: 'somewhere/else/else' }
      end.to change(Redirect, :count)
    end
  end

  describe '#edit' do
    before(:each) do
      get :edit, id: FactoryGirl.create(:redirect).id
    end

    it 'should render new template with valid redirect' do
      assert_template 'edit'
      expect(assigns(:redirect)).not_to be_nil
      assert assigns(:redirect).valid?
    end
  end

  describe '#update' do
    it 'redirects afterwards' do
      post :update, id: FactoryGirl.create(:redirect).id, redirect: {}
      assert_response :redirect, action: 'index'
    end
  end

  describe '#remove' do
    before(:each) do
      @test_id = FactoryGirl.create(:redirect).id
      get :remove, id: @test_id
    end

    it 'should render remove template' do
      assert_response :success
      assert_template 'remove'
    end
  end

  describe '#destroy' do
    before(:each) do
      @test_id = FactoryGirl.create(:redirect).id
      expect(Redirect.find(@test_id)).not_to be_nil
    end


    describe 'with POST' do
      before(:each) do
        delete :destroy, id: @test_id
      end

      it 'should redirect to index' do
        assert_response :redirect, action: 'index'
      end

      it 'should have no more redirects' do
        expect { Redirect.find(@test_id) }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
