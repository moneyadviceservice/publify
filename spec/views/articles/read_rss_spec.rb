describe 'articles/read.rss.builder', type: :view do
  let!(:blog) { build_stubbed :blog }

  describe 'with one comment' do
    let(:article) { stub_full_article }
    let(:comment) { build(:comment, article: article, body: 'Comment body') }

    before(:each) do
      assign(:feedback, [comment])
      render
    end

    it 'renders an RSS feed with one item' do
      assert_rss20 rendered, 1
    end
  end
end
