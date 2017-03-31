RSpec.describe 'sitemaps/show.xml.builder', type: :view do
  let!(:blog) { build_stubbed :blog }

  before do
    assign(:items, [article])

    render
  end

  context 'untagged articles' do
    let(:article) { create :article, permalink: 'how-to-save-a-life' }

    it 'shows article sitemap' do
      expect(rendered).to include('<loc>http://test.host/how-to-save-a-life</loc>')
    end
  end

  context 'tagged articles' do
    let(:tags) do
      [
        Tag.create(name: 'finance'),
        Tag.create(name: 'debt management'),
      ]
    end

    let(:article) { create :article, tags: tags, permalink: 'money-matters' }

    it 'shows xml items for articles only' do
      expect(rendered).to include('<loc>http://test.host/money-matters</loc>')
      expect(rendered).to_not include('<loc>http://test.host/finance</loc>')
      expect(rendered).to_not include('<loc>http://test.host/debt-management</loc>')
    end
  end
end
