shared_examples_for 'CommentSanitization' do
  before do
    @blog = build_stubbed(:blog)
    @article = build_stubbed(:article, created_at: Time.now, published_at: Time.now)
    allow(Article).to receive(:find).and_return(@article)
    @blog.plugin_avatar = ''
    @blog.lang = 'en_US'

    Comment.with_options(body: 'test foo <script>do_evil();</script>',
                         author: 'Bob', article: @article,
                         created_at: Time.now) do |klass|
      @comment = klass.new(comment_options)
    end

    allow(@comment).to receive(:id).and_return(1)
    assign(:comment, @comment)
  end

  ['', 'markdown', 'textile', 'smartypants', 'markdown smartypants'].each do |value|
    it "Should sanitize content rendered with the #{value} textfilter" do
      @blog.comment_text_filter = value
      build_stubbed(value.empty? ? 'none' : value)

      render partial: 'articles/comment', object: @comment
      expect(rendered).to have_selector('.t-comment-content')
      expect(rendered).to have_selector('.t-comment-author')

      expect(rendered).not_to have_selector('.t-comment-content script')
      expect(rendered).not_to have_selector('.t-comment-content a:not([rel=nofollow])')
      # No links with javascript
      expect(rendered).not_to have_selector('.t-comment-content a[onclick]')
      expect(rendered).not_to have_selector(".t-comment-content a[href^=\"javascript:\"]")

      expect(rendered).not_to have_selector('.t-comment-author script')
      expect(rendered).not_to have_selector('.t-comment-author a:not([rel=nofollow])')
      # No links with javascript
      expect(rendered).not_to have_selector('.t-comment-author a[onclick]')
      expect(rendered).not_to have_selector(".t-comment-author a[href^=\"javascript:\"]")
    end
  end
end

describe 'First dodgy comment', type: :view do
  it_should_behave_like 'CommentSanitization'

  def comment_options
    { body: 'test foo <script>do_evil();</script>' }
  end
end

describe 'Second dodgy comment', type: :view do
  it_should_behave_like 'CommentSanitization'

  def comment_options
    { body: 'link to [spammy goodness](http://spammer.example.com)' }
  end
end

describe 'Dodgy comment #3', type: :view do
  it_should_behave_like 'CommentSanitization'

  def comment_options
    { body: 'link to <a href="spammer.com">spammy goodness</a>' }
  end
end

describe 'Extra Dodgy comment', type: :view do
  it_should_behave_like 'CommentSanitization'

  def comment_options
    { body: '<a href="http://spam.org">spam</a>',
      author: '<a href="http://spamme.com>spamme</a>',
      email: '<a href="http://itsallspam.com/">its all spam</a>' }
  end
end

describe 'XSS1', type: :view do
  it_should_behave_like 'CommentSanitization'

  def comment_options
    { body: %{Have you ever <script lang="javascript">alert("foo");</script> been hacked?} }
  end
end

describe 'XSS2', type: :view do
  it_should_behave_like 'CommentSanitization'
  def comment_options
    { body: %{<a href="#" onclick="javascript">bad link</a>} }
  end
end

describe 'XSS2', type: :view do
  it_should_behave_like 'CommentSanitization'

  def comment_options
    { body: %{<a href="javascript:bad">bad link</a>} }
  end
end

describe 'Comment with bare http URL', type: :view do
  it_should_behave_like 'CommentSanitization'

  def comment_options
    { body: %{http://www.example.com} }
  end
end

describe 'Comment with bare email address', type: :view do
  it_should_behave_like 'CommentSanitization'

  def comment_options
    { body: %{foo@example.com} }
  end
end

shared_examples_for 'CommentSanitizationWithDofollow' do
  before do
    @blog = FactoryBot.create(:blog)
    @article = FactoryBot.create(:article, created_at: Time.now, published_at: Time.now)
    allow(Article).to receive(:find).and_return(@article)
    @blog.plugin_avatar = ''
    @blog.lang = 'en_US'
    @blog.dofollowify = true

    Comment.with_options(body: 'test foo <script>do_evil();</script>',
                         author: 'Bob', article: @article,
                         created_at: Time.now) do |klass|
      @comment = klass.new(comment_options)
    end

    allow(@comment).to receive(:id).and_return(1)
    assign(:comment, @comment)
  end

  ['', 'markdown', 'textile', 'smartypants', 'markdown smartypants'].each do |value|
    it "Should sanitize content rendered with the #{value} textfilter" do
      value == '' ? FactoryBot.create(:none) : FactoryBot.create(value)
      @blog.comment_text_filter = value
      @blog.save

      render partial: 'articles/comment', object: @comment
      expect(rendered).to have_selector('.comment-list-item')
      expect(rendered).to have_selector('.comment-list-item .t-comment-author')

      expect(rendered).not_to have_selector('.t-comment-content script')
      expect(rendered).not_to have_selector('.t-comment-content a[rel=nofollow]')
      # No links with javascript
      expect(rendered).not_to have_selector('.t-comment-content a[onclick]')
      expect(rendered).not_to have_selector(".t-comment-content a[href^=\"javascript:\"]")

      expect(rendered).not_to have_selector('.t-comment-author script')
      expect(rendered).not_to have_selector('.t-comment-author a[rel=nofollow]')
      # No links with javascript
      expect(rendered).not_to have_selector('.t-comment-author a[onclick]')
      expect(rendered).not_to have_selector(".t-comment-author a[href^=\"javascript:\"]")
    end
  end
end

describe 'First dodgy comment with dofollow', type: :view do
  it_should_behave_like 'CommentSanitizationWithDofollow'

  def comment_options
    { body: 'test foo <script>do_evil();</script>' }
  end
end

describe 'Second dodgy comment with dofollow', type: :view do
  it_should_behave_like 'CommentSanitizationWithDofollow'

  def comment_options
    { body: 'link to [spammy goodness](http://spammer.example.com)' }
  end
end

describe 'Dodgy comment #3 with dofollow', type: :view do
  it_should_behave_like 'CommentSanitizationWithDofollow'

  def comment_options
    { body: 'link to <a href="spammer.com">spammy goodness</a>' }
  end
end

describe 'Extra Dodgy comment with dofollow', type: :view do
  it_should_behave_like 'CommentSanitizationWithDofollow'

  def comment_options
    { body: '<a href="http://spam.org">spam</a>',
      author: '<a href="http://spamme.com>spamme</a>',
      email: '<a href="http://itsallspam.com/">its all spam</a>' }
  end
end

describe 'XSS1 with dofollow', type: :view do
  it_should_behave_like 'CommentSanitizationWithDofollow'

  def comment_options
    { body: %{Have you ever <script lang="javascript">alert("foo");</script> been hacked?} }
  end
end

describe 'XSS2 with dofollow', type: :view do
  it_should_behave_like 'CommentSanitizationWithDofollow'
  def comment_options
    { body: %{<a href="#" onclick="javascript">bad link</a>} }
  end
end

describe 'XSS2 with dofollow', type: :view do
  it_should_behave_like 'CommentSanitizationWithDofollow'

  def comment_options
    { body: %{<a href="javascript:bad">bad link</a>} }
  end
end

describe 'Comment with bare http URL with dofollow', type: :view do
  it_should_behave_like 'CommentSanitizationWithDofollow'

  def comment_options
    { body: %{http://www.example.com} }
  end
end

describe 'Comment with bare email address with dofollow', type: :view do
  it_should_behave_like 'CommentSanitizationWithDofollow'

  def comment_options
    { body: %{foo@example.com} }
  end
end
