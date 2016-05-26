# coding: utf-8
describe 'articles/index.rss.builder', type: :view do
  let!(:blog) { build_stubbed :blog }

  describe 'rendering articles (with some funny characters)' do
    before do
      article1 = stub_full_article(1.minute.ago)
      article1.body = '&eacute;coute!'
      article2 = stub_full_article(2.minutes.ago)
      article2.body = 'is 4 < 2? no!'
      assign(:articles, [article1, article2])
      render
    end

    it 'creates an RSS feed with two items' do
      assert_rss20 rendered, 2
    end

    it 'renders the article RSS partial twice' do
      expect(view).to render_template(partial: 'shared/_rss_item_article', count: 2)
    end
  end

  describe 'rendering a single article' do
    before do
      @article = stub_full_article
      @article.body = 'public info'
      @article.extended = 'and more'
      assign(:articles, [@article])
    end

    it 'has the correct guid' do
      render
      expect(rendered_entry.css('guid').first.content).to eq("urn:uuid:#{@article.guid}")
    end

    it "has a link to the article's comment section" do
      render
      expect(rendered_entry.css('comments').first.content).to eq("#{article_url(@article.permalink)}#comments")
    end

    describe 'with an author without email set' do
      before(:each) do
        @article.user.email = nil
        render
      end

      it 'has an author entry' do
        expect(rendered_entry.css('author')).to_not be_empty
      end
    end

    describe 'with an author with email set' do
      before(:each) do
        @article.user.email = 'foo@bar.com'
      end

      describe 'on a blog that links to the author' do
        before(:each) do
          Blog.default.link_to_author = true
          render
        end

        it 'has an author entry' do
          expect(rendered_entry.css('author')).not_to be_empty
        end

        it "has the blog email in the author entry" do
          expect(rendered_entry.css('author').first.content).to match(/blog@moneyadviceservice.org.uk/)
        end
      end
    end

    describe 'on a blog that shows extended content in feeds' do
      before(:each) do
        Blog.default.hide_extended_on_rss = false
        render
      end

      it 'shows the body and extended content in the feed' do
        expect(rendered_entry.css('description').first.content).to match(/public info.*and more/m)
      end
    end

    describe 'on a blog that hides extended content in feeds' do
      before(:each) do
        Blog.default.hide_extended_on_rss = true
      end

      it 'shows only the body content in the feed if there is no excerpt' do
        render
        entry = rendered_entry
        expect(entry.css('description').first.content).to match(/public info/)
        expect(entry.css('description').first.content).not_to match(/public info.*and more/m)
      end

      it 'shows the excerpt instead of the body content in the feed, if there is an excerpt' do
        @article.excerpt = 'excerpt'
        render
        entry = rendered_entry
        expect(entry.css('description').first.content).to match(/excerpt/)
        expect(entry.css('description').first.content).not_to match(/public info/)
      end
    end

    describe 'on a blog that has an RSS description set' do
      before(:each) do
        Blog.default.rss_description = true
        Blog.default.rss_description_text = 'rss description'
        render
      end

      it 'shows the body content in the feed' do
        expect(rendered_entry.css('description').first.content).to match(/public info/)
      end

      it 'shows the RSS description in the feed' do
        expect(rendered_entry.css('description').first.content).to match(/rss description/)
      end
    end

  end

  describe 'rendering an article with a UTF-8 permalink' do
    before(:each) do
      @article = stub_full_article
      @article.permalink = 'ルビー'
      assign(:articles, [@article])

      render
    end

    it 'creates a valid feed' do
      expect(Nokogiri::XML.parse(rendered)).to be_truthy
    end
  end

  def rendered_entry
    parsed = Nokogiri::XML.parse(rendered)
    parsed.css('item').first
  end

  describe '#title' do
    before(:each) do
      assign(:articles, [article])
      render
    end

    context 'with a note' do
      let(:article) { create(:note) }
      it { expect(rendered_entry.css('title').text).to eq(article.body) }
    end

    context 'with an article' do
      let(:article) { create(:article) }
      it { expect(rendered_entry.css('title').text).to eq(article.title) }
    end
  end

end
