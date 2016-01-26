describe Admin::ProfilesController, type: :controller do
  let!(:blog) { create(:blog) }
  let(:alice) { create(:user, login: 'alice', profile: create(:profile_admin, label: Profile::ADMIN)) }

  describe '#edit' do
    it 'redirects to profile page' do
      request.session = { user: alice.id }
      get :edit
      expect(response).to render_template('edit')
    end
  end

  describe '#post' do
    before do
      request.session = { user: alice.id }
      post :update, user: { email: 'foo@bar.com' }
    end

    it 'updates alices profile' do
      expect(alice.reload.email).to eq('foo@bar.com')
    end

    it 'redirects to profile page' do
      expect(response).to redirect_to(admin_dashboard_path)
    end
  end
end
