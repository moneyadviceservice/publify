describe Tag, type: :model do
  let!(:blog) { create(:blog) }

  it 'tags are unique' do
    expect { Tag.create!(name: 'test') }.not_to raise_error
    test_tag = Tag.new(name: 'test')
    expect(test_tag).not_to be_valid
    expect(test_tag.errors[:name]).to include('has already been taken')
  end

  it 'display names with spaces can be found by dash joined name' do
    expect(Tag.where(name: 'Monty Python').first).to be_nil
    tag = Tag.create(name: 'Monty Python')
    expect(tag).to be_valid
    expect(tag.name).to eq('monty-python')
    expect(tag.display_name).to eq('Monty Python')
  end

  it 'articles can be tagged' do
    a = Article.create(title: 'an article')
    foo = FactoryBot.create(:tag, name: 'foo')
    bar = FactoryBot.create(:tag, name: 'bar')
    a.tags << foo
    a.tags << bar
    a.reload
    expect(a.tags.size).to eq(2)
    expect(a.tags.sort_by(&:id)).to eq([foo, bar].sort_by(&:id))
  end

  it 'find_all_with_article_counters finds 2 tags' do
    a = FactoryBot.create(:article, title: 'an article a')
    b = FactoryBot.create(:article, title: 'an article b')
    c = FactoryBot.create(:article, title: 'an article c')
    foo = FactoryBot.create(:tag, name: 'foo', articles: [a, b, c])
    bar = FactoryBot.create(:tag, name: 'bar', articles: [a, b])
    tags = Tag.find_all_with_article_counters
    expect(tags.entries.size).to eq(2)
    expect(tags.first.name).to eq('foo')
    expect(tags.first.article_counter).to eq(3)
    expect(tags.last.name).to eq('bar')
    expect(tags.last.article_counter).to eq(2)
  end

  describe '#published_articles' do
    it 'should return only published articles' do
      published_art = FactoryBot.create(:article)
      draft_art = FactoryBot.create(:article, published_at: nil, published: false, state: 'draft')
      art_tag = FactoryBot.create(:tag, name: 'art', articles: [published_art, draft_art])
      expect(art_tag.published_articles.size).to eq(1)
    end
  end

  context 'with tags foo, bar and bazz' do

    before do
      @foo = FactoryBot.create(:tag, name: 'foo')
      @bar = FactoryBot.create(:tag, name: 'bar')
      @bazz = FactoryBot.create(:tag, name: 'bazz')
    end

    it "find_with_char('f') should be return foo" do
      expect(Tag.find_with_char('f')).to eq([@foo])
    end

    it "find_with_char('v') should return empty data" do
      expect(Tag.find_with_char('v')).to eq([])
    end

    it "find_with_char('ba') should return tag bar and bazz" do
      expect(Tag.find_with_char('ba').sort_by(&:id)).to eq([@bar, @bazz].sort_by(&:id))
    end

    describe '#create_from_article' do
      before(:each) { Tag.create_from_article!(article) }

      context 'without keywords' do
        let(:article) { create(:article, keywords: nil) }
        it { expect(article.tags).to be_empty }
      end

      context 'with a simple keyword' do
        let(:article) { create(:article, keywords: 'foo') }
        it { expect(article.tags.size).to eq(1) }
        it { expect(article.tags.first).to be_kind_of(Tag) }
        it { expect(article.tags.first.name).to eq('foo') }
      end

      context 'with two keyword separate by a coma' do
        let(:article) { create(:article, keywords: 'foo, bar') }
        it { expect(article.tags.size).to eq(2) }
        it { expect(article.tags.map(&:name)).to eq(['foo', 'bar']) }
      end

      context 'with two keyword with apostrophe' do
        let(:article) { create(:article, keywords: "foo, l'bar") }
        it { expect(article.tags.size).to eq(3) }
        it { expect(article.tags.map(&:name)).to eq(['foo', 'l', 'bar']) }
      end

      context 'with two identical keywords' do
        let(:article) { create(:article, keywords: "same'same") }
        it { expect(article.tags.size).to eq(1) }
        it { expect(article.tags.map(&:name)).to eq(['same']) }
      end
    end

  end
end
