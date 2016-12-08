# coding: utf-8
describe AMPProcessor, type: :model do
  let!(:blog) { create(:blog) }

  let!(:blog) { create(:blog) }
  let(:article) { create(:article, permalink: 'second-blog-article', published_at: '2004-04-01 02:00:00', updated_at: '2004-04-01 02:00:00', created_at: '2004-04-01 02:00:00', supports_amp: true) }
  let(:processor) { AMPProcessor.new(article) }

  describe '#call' do
    before(:each) do
      expect(article).to receive(:html).with(:body).and_return(body)
    end

    context 'no special tags in html' do
      let(:body) { '<div>html</div>' }

      it 'returns some html' do
        expect(processor.call).to eq(body)
      end
    end

    context 'blog contains an image tag' do
      let(:src) { 'http://animage.com' }
      let(:body) { "<img alt='something' src='#{src}'/>" }

      before(:each) do
        expect(FastImage).to receive(:size).with(src).and_return(fast_image_response)
      end

      context 'image exists' do
        let(:fast_image_response) { [44, 52] }
        let(:replaced_html) { "<amp-img alt=\"something\" src=\"#{src}\" layout=\"responsive\" width=\"44\" height=\"52\"></amp-img>" }

        it 'replaces the image tag with an amp-image tag' do
          expect(processor.call).to eq(replaced_html)
        end
      end

      context 'image does not exists' do
        let(:fast_image_response) { nil }

        it 'removes the image tag' do
          expect(processor.call).to eq('')
        end
      end
    end

    context 'blog contains an iframe' do
      let(:src) { '//aniframe.com' }
      let(:body) { "<iframe width='44' height='52' src='#{src}'/>" }

        let(:replaced_html) { "<amp-iframe width=\"44\" height=\"52\" layout=\"responsive\" sandbox=\"allow-scripts allow-same-origin\" allowfullscreen frameborder=\"0\" src=\"https:#{src}\"></amp-iframe>" }

        it 'replaces the iframe tag with an amp-iframe tag' do
          expect(processor.call).to eq(replaced_html)
        end
    end
  end
end
