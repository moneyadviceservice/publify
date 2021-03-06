RSpec.describe 'sitemaps/show.xml.builder', type: :view do
  describe 'rendered xml document' do
    let!(:blog) { build_stubbed :blog }

    before do
      assign(:items, [article])

      render
    end

    context 'untagged articles' do
      let(:article) { create :article, permalink: 'how-to-save-a-life' }

      it 'shows article sitemap' do
        expect(rendered).to include('<loc>http://test.host/blog/how-to-save-a-life</loc>')
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
        expect(rendered).to include('<loc>http://test.host/blog/money-matters</loc>')
      end

      it 'does not show xml items for article tags' do
        expect(rendered).to_not include('<loc>http://test.host/blog/finance</loc>')
        expect(rendered).to_not include('<loc>http://test.host/blog/debt-management</loc>')
      end
    end
  end

  describe 'exclude page' do
    it 'does not show page items' do
      expect(rendered).to_not include('<loc>http://test.host/blog/commenting-policy</loc>')
    end
  end
end
