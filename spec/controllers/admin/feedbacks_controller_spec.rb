describe Admin::FeedbacksController, type: :controller do

  shared_examples_for 'destroy feedback with feedback from own article' do
    it 'should not destroy feedback in get request' do
      id = feedback_from_own_article.id
      expect do
        get 'remove', id: id
      end.not_to change(Feedback, :count)
      expect do
        Feedback.find(feedback_from_own_article.id)
      end.not_to raise_error
      expect(response).to render_template 'remove'
    end

    it 'should destroy the feedback on the destroy action' do
      id = feedback_from_own_article.id
      expect do
        delete 'destroy', id: id
      end.to change(Feedback, :count)
      expect do
        Feedback.find(feedback_from_own_article.id)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'should redirect to feedback from article' do
      delete 'destroy', id: feedback_from_own_article.id
      expect(response).to redirect_to(admin_feedbacks_path(article_id: feedback_from_own_article.article))
    end
  end

  describe 'logged in admin user' do

    before(:each) do
      create(:blog)
      @admin = create(:user, :as_admin)
      request.session = { user: @admin.id }
    end

    def feedback_from_own_article
      @article ||= FactoryBot.create(:article, user: @admin)
      @comment_own ||= FactoryBot.create(:comment, article: @article)
    end

    def feedback_from_not_own_article
      @spam_comment_not_own ||= FactoryBot.create(:spam_comment)
    end

    describe 'remove and destroy actions' do

      it_should_behave_like 'destroy feedback with feedback from own article'

      it "should destroy feedback from article doesn't own" do
        id = feedback_from_not_own_article.id
        expect do
          delete 'destroy', id: id
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
        article = FactoryBot.create(:article)
        comment = FactoryBot.create(:comment, article: article)
        get 'edit', id: comment.id
        expect(response).to be_success
        expect(response).to render_template('edit')
      end
    end

    describe 'update action' do

      it 'should update comment if post request' do
        article = FactoryBot.create(:article)
        comment = FactoryBot.create(:comment, article: article)
        post 'update', id: comment.id,
                       comment: { author: 'Bob Foo2',
                                    url: 'http://fakeurl.com',
                                    body: 'updated comment' }
        expect(response).to redirect_to(admin_feedbacks_path(article_id: article))
        comment.reload
        expect(comment.body).to eq('updated comment')
      end
    end
  end

  describe 'publisher access' do

    before :each do
      FactoryBot.create(:blog)
      #TODO remove this delete_all after removing all fixture
      Profile.delete_all
      @publisher = FactoryBot.create(:user, profile: FactoryBot.create(:profile_publisher))
      request.session = { user: @publisher.id }
    end

    def feedback_from_own_article
      @article ||= FactoryBot.create(:article, user: @publisher)
      @feedback_own_article ||= FactoryBot.create(:comment, article: @article)
    end

    def feedback_from_not_own_article
      @article ||= FactoryBot.create(:article, user: FactoryBot.create(:user, login: 'other_user'))
      @feedback_not_own_article ||= FactoryBot.create(:comment, article: @article)
    end

    describe 'destroy action' do
      it_should_behave_like 'destroy feedback with feedback from own article'
    end

    describe 'edit action' do
      it 'should show the edit form' do
        get 'edit', id: feedback_from_own_article.id
        expect(response).to be_success
        expect(response).to render_template('edit')
      end
    end

    describe 'update action' do
      it 'should update comment if own article' do
        feedback = feedback_from_own_article
        put 'update', id: feedback.id,
                       comment: { author: 'Bob Foo2',
                                    url: 'http://fakeurl.com',
                                    body: 'updated comment' }
        expect(response).to redirect_to(admin_feedbacks_path(article_id: feedback.article))
        feedback.reload
        expect(feedback.body).to eq('updated comment')
      end
    end

    describe '#bulkops action' do
      it 'redirect to index' do
        post :bulkops, bulkop_top: 'destroy all spam'
        expect(@response).to redirect_to(action: 'index')
      end

      it 'delete all spam' do
        Feedback.delete_all
        comment = FactoryBot.create(:comment, state: :spam)
        post :bulkops, bulkop_top: 'Delete all spam'
        expect(Feedback.count).to eq(0)
      end

      it 'delete all spam and only confirmed spam' do
        Feedback.delete_all
        FactoryBot.create(:comment, state: :presumed_spam)
        FactoryBot.create(:comment, state: :spam)
        FactoryBot.create(:comment, state: :presumed_ham)
        FactoryBot.create(:comment, state: :ham)
        post :bulkops, bulkop_top: 'Delete all spam'
        expect(Feedback.count).to eq(3)
      end

      it 'mark presumed spam comments as spam' do
        comment = FactoryBot.create(:comment, state: :presumed_spam)
        post :bulkops, bulkop_top: 'Mark Checked Items as Spam', feedback_check: { comment.id.to_s => 'on' }
        expect(Feedback.find(comment.id)).to be_spam
      end

      it 'mark confirmed spam comments as spam' do
        comment = FactoryBot.create(:comment, state: :spam)
        post :bulkops, bulkop_top: 'Mark Checked Items as Spam', feedback_check: { comment.id.to_s => 'on' }
        expect(Feedback.find(comment.id)).to be_spam
      end

      it 'mark presumed ham comments as spam' do
        comment = FactoryBot.create(:comment, state: :presumed_ham)
        post :bulkops, bulkop_top: 'Mark Checked Items as Spam', feedback_check: { comment.id.to_s => 'on' }
        expect(Feedback.find(comment.id)).to be_spam
      end

      it 'mark ham comments as spam' do
        comment = FactoryBot.create(:comment, state: :ham)
        post :bulkops, bulkop_top: 'Mark Checked Items as Spam', feedback_check: { comment.id.to_s => 'on' }
        expect(Feedback.find(comment.id)).to be_spam
      end

      it 'mark presumed spam comments as ham' do
        comment = FactoryBot.create(:comment, state: :presumed_spam)
        post :bulkops, bulkop_top: 'Mark Checked Items as Ham', feedback_check: { comment.id.to_s => 'on' }
        expect(Feedback.find(comment.id)).to be_ham
      end

      it 'mark confirmed spam comments as ham' do
        comment = FactoryBot.create(:comment, state: :spam)
        post :bulkops, bulkop_top: 'Mark Checked Items as Ham', feedback_check: { comment.id.to_s => 'on' }
        expect(Feedback.find(comment.id)).to be_ham
      end

      it 'mark presumed ham comments as ham' do
        comment = FactoryBot.create(:comment, state: :presumed_ham)
        post :bulkops, bulkop_top: 'Mark Checked Items as Ham', feedback_check: { comment.id.to_s => 'on' }
        expect(Feedback.find(comment.id)).to be_ham
      end

      it 'mark ham comments as ham' do
        comment = FactoryBot.create(:comment, state: :ham)
        post :bulkops, bulkop_top: 'Mark Checked Items as Ham', feedback_check: { comment.id.to_s => 'on' }
        expect(Feedback.find(comment.id)).to be_ham
      end

    end
  end
end
