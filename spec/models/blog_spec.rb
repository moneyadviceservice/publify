describe Blog, type: :model do
  describe '#initialize' do
    it 'accepts a settings field in its parameter hash' do
      Blog.new('blog_name' => 'foo')
    end
  end

  describe 'A blog' do
    before(:each) do
      Rails.cache.clear
      @blog = Blog.new
    end

    it 'values boolify like Perl' do
      { '0 but true' => true, '' => false, 'false' => false, 1 => true, 0 => false, nil => false, 'f' => false }.each do |value, expected|
        @blog.sp_global = value
        expect(@blog.sp_global).to eq(expected)
      end
    end
  end

  describe 'The first blog' do
    before(:each) {
      @blog = FactoryBot.create :blog
    }

    it 'should be the only blog allowed' do
      expect(Blog.new).not_to be_valid
    end
  end

  describe 'The default blog' do
    it 'should pick up updates after a cache clear' do
      FactoryBot.create(:blog)
      b = Blog.default
      b.blog_name = 'some other name'
      b.save
      c = Blog.default
      expect(c.blog_name).to eq('some other name')
    end
  end

  describe 'Given no blogs, a new default blog' do
    before :each do
      @blog = Blog.new
    end

    it 'should be valid after filling the title' do
      @blog.blog_name = 'something not empty'
      expect(@blog).to be_valid
    end

    it 'should be valid without filling the title' do
      expect(@blog.blog_name).to eq('My Shiny Weblog!')
      expect(@blog).to be_valid
    end

    it 'should not be valid after setting an empty title' do
      @blog.blog_name = ''
      expect(@blog).not_to be_valid
    end
  end

  describe '.meta_keywords' do
    it 'return empty string when nothing' do
      blog = Blog.new
      expect(blog.meta_keywords).to eq ''
    end

    it 'return meta keywords when exist' do
      blog = Blog.new(meta_keywords: 'key')
      expect(blog.meta_keywords).to eq 'key'
    end
  end

  describe '.meta_description' do
    it 'return empty string when nothing' do
      blog = Blog.new
      expect(blog.meta_description).to eq ''
    end

    it 'return meta keywords when exist' do
      blog = Blog.new(meta_description: 'key')
      expect(blog.meta_description).to eq 'key'
    end
  end

  describe '.urls_to_ping_for' do
    it 'format ping_urls to an array' do
      article = Article.new
      blog = FactoryBot.build(:blog, ping_urls: 'http://ping.example.com/ping')
      expect(blog.urls_to_ping_for(article).map(&:url)).to eq ['http://ping.example.com/ping']
    end

    it 'format ping_urls to an array even when multiple urls' do
      article = Article.new
      blog = FactoryBot.build(:blog, ping_urls: "http://ping.example.com/ping
http://anotherurl.net/other_line")
      expect(blog.urls_to_ping_for(article).map(&:url)).to eq ['http://ping.example.com/ping', 'http://anotherurl.net/other_line']
    end
  end

  describe 'Blog Twitter configuration' do
    it 'A blog without :twitter_consumer_key or twitter_consumer_secret should not have Twitter configured' do
      blog = FactoryBot.build(:blog)
      expect(blog.has_twitter_configured?).to eq(false)
    end

    it 'A blog with an empty :twitter_consumer_key and no twitter_consumer_secret should not have Twitter configured' do
      blog = FactoryBot.build(:blog, twitter_consumer_key: '')
      expect(blog.has_twitter_configured?).to eq(false)
    end

    it 'A blog with an empty twitter_consumer_key and an empty twitter_consumer_secret should not have Twitter configured' do
      blog = FactoryBot.build(:blog, twitter_consumer_key: '', twitter_consumer_secret: '')
      expect(blog.has_twitter_configured?).to eq(false)
    end

    it 'A blog with a twitter_consumer_key and no twitter_consumer_secret should not have Twitter configured' do
      blog = FactoryBot.build(:blog, twitter_consumer_key: '12345')
      expect(blog.has_twitter_configured?).to eq(false)
    end

    it 'A blog with a twitter_consumer_key and an empty twitter_consumer_secret should not have Twitter configured' do
      blog = FactoryBot.build(:blog, twitter_consumer_key: '12345', twitter_consumer_secret: '')
      expect(blog.has_twitter_configured?).to eq(false)
    end

    it 'A blog with a twitter_consumer_secret and no twitter_consumer_key should not have Twitter configured' do
      blog = FactoryBot.build(:blog, twitter_consumer_secret: '67890')
      expect(blog.has_twitter_configured?).to eq(false)
    end

    it 'A blog with a twitter_consumer_secret and an empty twitter_consumer_key should not have Twitter configured' do
      blog = FactoryBot.build(:blog, twitter_consumer_secret: '67890', twitter_consumer_key: '')
      expect(blog.has_twitter_configured?).to eq(false)
    end

    it 'A blog with a twitter_consumer_key and a twitter_consumer_secret should have Twitter configured' do
      blog = FactoryBot.build(:blog, twitter_consumer_key: '12345', twitter_consumer_secret: '67890')
      expect(blog.has_twitter_configured?).to eq(true)
    end
  end

  describe '#per_page' do
    let(:blog) { create(:blog, limit_article_display: 3, limit_rss_display: 4) }
    it { expect(blog.per_page(nil)).to eq(3) }
    it { expect(blog.per_page('html')).to eq(3) }
    it { expect(blog.per_page('rss')).to eq(4) }
    it { expect(blog.per_page('atom')).to eq(4) }
  end

end
