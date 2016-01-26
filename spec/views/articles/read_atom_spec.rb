describe 'articles/read.atom.builder', type: :view do
  let!(:blog) { create :blog }

  describe 'with a comment with problematic characters' do
    let(:article) { stub_full_article }
    let(:comment) { build(:comment, article: article, body: '&eacute;coute! 4 < 2, non?') }

    before(:each) do
      assign(:feedback, [comment])
      render
    end

    it 'should render an Atom feed with one item' do
      assert_atom10 rendered, 1
    end
  end
end
