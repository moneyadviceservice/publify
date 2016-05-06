describe Admin::UsersController, 'rough port of the old functional test', type: :controller do
  describe ' when you are admin' do
    before(:each) do
      create(:blog)
      @admin = create(:user, profile: create(:profile_admin, label: Profile::ADMIN))
      request.session = { user: @admin.id }
    end

    describe '#create' do
      it 'redirects after' do
        get :new
        assert_template 'new'

        post :create, user: { login: 'errand', email: 'corey@test.com', password: 'testpass', password_confirmation: 'testpass', profile_id: 1, nickname: 'fooo', firstname: 'bar' }
        expect(response).to redirect_to(admin_users_path)
      end
    end

    describe '#edit' do
      describe 'with id params' do
        before do
          get :edit, id: @admin.id
        end

        it 'should render template edit' do
          assert_template 'edit'
        end

        it 'should assigns tobi user' do
          assert assigns(:user).valid?
          expect(assigns(:user)).to eq(@admin)
        end
      end
    end
    
    describe '#update' do
      it 'should redirect to index' do
        post :update, id: @admin.id, user: { login: 'errand',
                                                 email: 'corey@test.com', password: 'testpass',
                                                 password_confirmation: 'testpass' }
        expect(response).to redirect_to(admin_users_path)
      end
    end
  end

  describe 'when you are not admin' do
    before :each do
      create(:blog)
      user = create(:user)
      session[:user] = user.id
    end

    it "don't see the list of user" do
      get :index
      expect(response).to redirect_to(admin_dashboard_path)
    end

    describe '#update' do
      describe 'try update another user' do
        before do
          @admin_profile = create(:profile_admin)
          @administrator = create(:user, profile: @admin_profile)
          contributor = create(:profile_contributor)
          post :update,
               id: @administrator.id,
               profile_id: contributor.id
        end

        it 'should redirect to login' do
          expect(response).to redirect_to(admin_dashboard_path)
        end

        it 'should not change user profile' do
          u = @administrator.reload
          expect(u.profile_id).to eq(@admin_profile.id)
        end
      end
    end
  end
end
