require 'rails_helper'

describe Admin::DashboardController, type: :controller do
  render_views

  describe 'test admin profile' do
    before do
      @blog ||= FactoryGirl.create(:blog)
      @henri = FactoryGirl.create(:user, login: 'henri', profile: FactoryGirl.create(:profile_admin, label: Profile::ADMIN))
      request.session = { user: @henri.id }
      get :index
    end

    it 'should render the index template' do
      expect(response.body).to render_template('index')
    end

    it 'should have a link to the sidebar' do
      expect(response.body).to have_selector("a[href='/admin/sidebar']", text: 'Customize sidebar')
    end

    it 'should have a link to a new article' do
      expect(response.body).to have_selector("a[href='/admin/content/new']", text: 'write a post')
    end

    it 'should have a link to a new page' do
      expect(response.body).to have_selector("a[href='/admin/pages/new']", text: 'write a page')
    end

    it 'should have a link to article listing' do
      expect(response.body).to have_selector("a[href='/admin/content']", text: 'no article')
    end

    it "should have a link to user's article listing" do
      expect(response.body).to have_selector("a[href='/admin/content?search%5Buser_id%5D=#{@henri.id}']", text: 'no article writen by you')
    end

    it 'should have a link to drafts' do
      expect(response.body).to have_selector("a[href='/admin/content?search%5Bstate%5D=drafts']", text: 'no draft')
    end

    it 'should have a link to pages' do
      expect(response.body).to have_selector("a[href='/admin/pages']", text: 'no page')
    end

    it 'should have a link to total comments' do
      expect(response.body).to have_selector("a[href='/admin/feedback']", text: 'no comment')
    end

    it 'should have a link to Spam' do
      expect(response.body).to have_selector("a[href='/admin/feedback?spam=f']", text: 'no spam')
    end

    it 'should have a link to Spam queue' do
      expect(response.body).to have_selector("a[href='/admin/feedback?presumed_ham=f']", text: 'no unconfirmed')
    end
  end

  describe 'test publisher profile' do
    before do
      @blog ||= FactoryGirl.create(:blog)
      # TODO Delete after removing fixtures
      Profile.delete_all
      @rene = FactoryGirl.create(:user, login: 'rene', profile: FactoryGirl.create(:profile_publisher, label: Profile::PUBLISHER))
      request.session = { user: @rene.id }
      get :index
    end

    it 'should render the index template' do
      expect(response.body).to render_template('index')
    end

    it 'should not have a link to the sidebar' do
      expect(response.body).not_to have_selector("a[href='/admin/sidebar']", text: 'enable plugins')
    end

    it 'should have a link to a new article' do
      expect(response.body).to have_selector("a[href='/admin/content/new']", text: 'write a post')
    end

    it 'should have a link to a new page' do
      expect(response.body).to have_selector("a[href='/admin/pages/new']", text: 'write a page')
    end

    it 'should have a link to article listing' do
      expect(response.body).to have_selector("a[href='/admin/content']", text: 'no article')
    end

    it "should have a link to user's article listing" do
      expect(response.body).to have_selector("a[href='/admin/content?search%5Buser_id%5D=#{@rene.id}']", text: 'no article writen by you')
    end

    it 'should have a link to total comments' do
      expect(response.body).to have_selector("a[href='/admin/feedback']", text: 'no comment')
    end

    it 'should have a link to Spam' do
      expect(response.body).to have_selector("a[href='/admin/feedback?spam=f']", text: 'no spam')
    end

    it 'should have a link to Spam queue' do
      expect(response.body).to have_selector("a[href='/admin/feedback?presumed_ham=f']", text: 'no unconfirmed')
    end
  end

  describe 'test contributor profile' do
    before do
      @blog ||= FactoryGirl.create(:blog)
      # TODO Delete after removing fixtures
      Profile.delete_all
      @gerard = FactoryGirl.create(:user, login: 'gerard', profile: FactoryGirl.create(:profile_contributor, label: Profile::CONTRIBUTOR))
      request.session = { user: @gerard.id }
      get :index
    end

    it 'should render the index template' do
      expect(response.body).to render_template('index')
    end

    it 'should not have a link to the sidebar' do
      expect(response.body).not_to have_selector("a[href='/admin/sidebar']", text: 'enable plugins')
    end

    it 'should not have a link to a new article' do
      expect(response.body).not_to have_selector("a[href='/admin/content/new']", text: 'write a post')
    end

    it 'should not have a link to a new article' do
      expect(response.body).not_to have_selector("a[href='/admin/pages/new']", text: 'write a page')
    end

    it 'should not have a link to article listing' do
      expect(response.body).not_to have_selector("a[href='/admin/content']", text: 'Total posts:')
    end

    it "should not have a link to user's article listing" do
      expect(response.body).not_to have_selector("a[href='/admin/content?search%5Buser_id%5D=#{@gerard.id}']", text: 'Your posts:')
    end

    it 'should not have a link to categories' do
      expect(response.body).not_to have_selector("a[href='/admin/categories']", text: 'Categories:')
    end

    it 'should not have a link to total comments' do
      expect(response.body).not_to have_selector("a[href='/admin/feedback']", text: 'Total comments:')
    end

    it 'should not have a link to Spam' do
      expect(response.body).not_to have_selector("a[href='/admin/feedback?published=f']", text: 'Spam comments:')
    end

    it 'should not have a link to Spam queue' do
      expect(response.body).not_to have_selector("a[href='/admin/feedback?presumed_spam=f']", text: 'In your spam queue:')
    end
  end
end
