describe Admin::FeedbacksController, type: :controller do

  shared_examples_for 'destroy feedback with feedback from own article' do
    it 'should destroy feedback' do
      id = feedback_from_own_article.id
      expect do
        post 'destroy', id: id
      end.to change(Feedback, :count)
      expect do
        Feedback.find(feedback_from_own_article.id)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'should redirect to feedback from article' do
      post 'destroy', id: feedback_from_own_article.id
      expect(response).to redirect_to(admin_feedbacks_path(article_id: feedback_from_own_article.article))
    end

    it 'should not destroy feedback in get request' do
      id = feedback_from_own_article.id
      expect do
        get 'destroy', id: id
      end.not_to change(Feedback, :count)
      expect do
        Feedback.find(feedback_from_own_article.id)
      end.not_to raise_error
      expect(response).to render_template 'destroy'
    end
  end

  describe 'logged in admin user' do

    before(:each) do
      create(:blog)
      @admin = create(:user, :as_admin)
      request.session = { user: @admin.id }
    end

    def feedback_from_own_article
      @article ||= FactoryGirl.create(:article, user: @admin)
      @comment_own ||= FactoryGirl.create(:comment, article: @article)
    end

    def feedback_from_not_own_article
      @spam_comment_not_own ||= FactoryGirl.create(:spam_comment)
    end

    describe 'destroy action' do

      it_should_behave_like 'destroy feedback with feedback from own article'

      it "should destroy feedback from article doesn't own" do
        id = feedback_from_not_own_article.id
        expect do
          post 'destroy', id: id
        end.to change(Feedback, :count)
        expect do
          Feedback.find(feedback_from_not_own_article.id)
        end.to raise_error(ActiveRecord::RecordNotFound)
        expect(response).to redirect_to(admin_feedbacks_path(article_id: feedback_from_not_own_article.article))
      end
    end

    describe 'index' do
      let!(:spam) { create(:spam_comment) }
      let!(:unapproved) { create(:unconfirmed_comment) }
      let!(:presumed_ham) { create(:presumed_ham_comment) }
      let!(:presumed_spam) { create(:presumed_spam_comment) }
      let(:params) {}

      before(:each) { get :index, params }

      it { expect(response).to be_success }
      it { expect(response).to render_template('index') }

      context 'simple' do
        it { expect(assigns(:feedback).size).to eq(4) }
      end

      context 'unaproved' do
        let(:params) { { only: 'unapproved' } }
        it { expect(assigns(:feedback)).to eq([unapproved, presumed_ham, presumed_spam]) }
      end

      context 'spam' do
        let(:params) { { only: 'spam' } }
        it { expect(assigns(:feedback)).to eq([spam, presumed_spam]) }
      end

      context 'presumed_spam' do
        let(:params) { { only: 'presumed_spam' } }
        it { expect(assigns(:feedback)).to eq([presumed_spam]) }
      end

      context 'presumed_ham' do
        let(:params) { { only: 'presumed_ham' } }
        it { expect(assigns(:feedback)).to eq([unapproved, presumed_ham]) }
      end

      context 'with an empty page params' do
        let(:params) { { page: '' } }
        it { expect(assigns(:feedback).size).to eq(4) }
      end
    end

    describe 'edit action' do
      it 'should render edit form' do
        article = FactoryGirl.create(:article)
        comment = FactoryGirl.create(:comment, article: article)
        get 'edit', id: comment.id
        expect(assigns(:comment)).to eq(comment)
        expect(assigns(:article)).to eq(article)
        expect(response).to be_success
        expect(response).to render_template('edit')
      end
    end

    describe 'update action' do

      it 'should update comment if post request' do
        article = FactoryGirl.create(:article)
        comment = FactoryGirl.create(:comment, article: article)
        post 'update', id: comment.id,
                       comment: { author: 'Bob Foo2',
                                    url: 'http://fakeurl.com',
                                    body: 'updated comment' }
        expect(response).to redirect_to(action: 'article', id: article.id)
        comment.reload
        expect(comment.body).to eq('updated comment')
      end

      it 'should not  update comment if get request' do
        comment = FactoryGirl.create(:comment)
        get 'update', id: comment.id,
                      comment: { author: 'Bob Foo2',
                                   url: 'http://fakeurl.com',
                                   body: 'updated comment' }
        expect(response).to redirect_to(action: 'edit', id: comment.id)
        comment.reload
        expect(comment.body).not_to eq('updated comment')
      end

    end
  end

  describe 'publisher access' do

    before :each do
      FactoryGirl.create(:blog)
      #TODO remove this delete_all after removing all fixture
      Profile.delete_all
      @publisher = FactoryGirl.create(:user, profile: FactoryGirl.create(:profile_publisher))
      request.session = { user: @publisher.id }
    end

    def feedback_from_own_article
      @article ||= FactoryGirl.create(:article, user: @publisher)
      @feedback_own_article ||= FactoryGirl.create(:comment, article: @article)
    end

    def feedback_from_not_own_article
      @article ||= FactoryGirl.create(:article, user: FactoryGirl.create(:user, login: 'other_user'))
      @feedback_not_own_article ||= FactoryGirl.create(:comment, article: @article)
    end

    describe 'destroy action' do
      it_should_behave_like 'destroy feedback with feedback from own article'

      it "should not destroy feedback doesn't own" do
        id = feedback_from_not_own_article.id
        post 'destroy', id: id
        expect(response).to redirect_to(admin_feedbacks_path)
        expect do
          Feedback.find(id)
        end.not_to raise_error
      end
    end

    describe 'edit action' do

      it 'should not edit comment no own article' do
        get 'edit', id: feedback_from_not_own_article.id
        expect(response).to redirect_to(action: 'index')
      end

      it 'should edit comment if own article' do
        get 'edit', id: feedback_from_own_article.id
        expect(response).to be_success
        expect(response).to render_template('edit')
        expect(assigns(:comment)).to eq(feedback_from_own_article)
        expect(assigns(:article)).to eq(feedback_from_own_article.article)
      end

    end

    describe 'update action' do

      it 'should update comment if own article' do
        post 'update', id: feedback_from_own_article.id,
                       comment: { author: 'Bob Foo2',
                                    url: 'http://fakeurl.com',
                                    body: 'updated comment' }
        expect(response).to redirect_to(action: 'article', id: feedback_from_own_article.article.id)
        feedback_from_own_article.reload
        expect(feedback_from_own_article.body).to eq('updated comment')
      end

      it 'should not update comment if not own article' do
        post 'update', id: feedback_from_not_own_article.id,
                       comment: { author: 'Bob Foo2',
                                    url: 'http://fakeurl.com',
                                    body: 'updated comment' }
        expect(response).to redirect_to(action: 'index')
        feedback_from_not_own_article.reload
        expect(feedback_from_not_own_article.body).not_to eq('updated comment')
      end
    end

    describe '#bulkops action' do
      it 'redirect to index' do
        post :bulkops, bulkop_top: 'destroy all spam'
        expect(@response).to redirect_to(action: 'index')
      end

      it 'delete all spam' do
        Feedback.delete_all
        comment = FactoryGirl.create(:comment, state: :spam)
        post :bulkops, bulkop_top: 'Delete all spam'
        expect(Feedback.count).to eq(0)
      end

      it 'delete all spam and only confirmed spam' do
        Feedback.delete_all
        FactoryGirl.create(:comment, state: :presumed_spam)
        FactoryGirl.create(:comment, state: :spam)
        FactoryGirl.create(:comment, state: :presumed_ham)
        FactoryGirl.create(:comment, state: :ham)
        post :bulkops, bulkop_top: 'Delete all spam'
        expect(Feedback.count).to eq(3)
      end

      it 'mark presumed spam comments as spam' do
        comment = FactoryGirl.create(:comment, state: :presumed_spam)
        post :bulkops, bulkop_top: 'Mark Checked Items as Spam', feedback_check: { comment.id.to_s => 'on' }
        expect(Feedback.find(comment.id)).to be_spam
      end

      it 'mark confirmed spam comments as spam' do
        comment = FactoryGirl.create(:comment, state: :spam)
        post :bulkops, bulkop_top: 'Mark Checked Items as Spam', feedback_check: { comment.id.to_s => 'on' }
        expect(Feedback.find(comment.id)).to be_spam
      end

      it 'mark presumed ham comments as spam' do
        comment = FactoryGirl.create(:comment, state: :presumed_ham)
        post :bulkops, bulkop_top: 'Mark Checked Items as Spam', feedback_check: { comment.id.to_s => 'on' }
        expect(Feedback.find(comment.id)).to be_spam
      end

      it 'mark ham comments as spam' do
        comment = FactoryGirl.create(:comment, state: :ham)
        post :bulkops, bulkop_top: 'Mark Checked Items as Spam', feedback_check: { comment.id.to_s => 'on' }
        expect(Feedback.find(comment.id)).to be_spam
      end

      it 'mark presumed spam comments as ham' do
        comment = FactoryGirl.create(:comment, state: :presumed_spam)
        post :bulkops, bulkop_top: 'Mark Checked Items as Ham', feedback_check: { comment.id.to_s => 'on' }
        expect(Feedback.find(comment.id)).to be_ham
      end

      it 'mark confirmed spam comments as ham' do
        comment = FactoryGirl.create(:comment, state: :spam)
        post :bulkops, bulkop_top: 'Mark Checked Items as Ham', feedback_check: { comment.id.to_s => 'on' }
        expect(Feedback.find(comment.id)).to be_ham
      end

      it 'mark presumed ham comments as ham' do
        comment = FactoryGirl.create(:comment, state: :presumed_ham)
        post :bulkops, bulkop_top: 'Mark Checked Items as Ham', feedback_check: { comment.id.to_s => 'on' }
        expect(Feedback.find(comment.id)).to be_ham
      end

      it 'mark ham comments as ham' do
        comment = FactoryGirl.create(:comment, state: :ham)
        post :bulkops, bulkop_top: 'Mark Checked Items as Ham', feedback_check: { comment.id.to_s => 'on' }
        expect(Feedback.find(comment.id)).to be_ham
      end

    end
  end
end
