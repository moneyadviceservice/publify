describe SitemapsController, type: :controller do
  before do
    create(:blog, base_url: 'http://myblog.net')
    allow(Trigger).to receive(:fire) {}
  end

  describe '#show' do
    context 'when the news param is not set' do
      before do
        FactoryBot.create(:tag)
        get :show, format: 'xml'
      end

      it 'is succesful' do
        assert_response :success
      end

      it 'returns a valid XML response' do
        assert_xml @response.body
      end
    end

    context 'when the news param is set' do
      before do
        FactoryBot.create(:tag)
        get :show, format: 'xml', news: true
      end

      it 'is succesful' do
        assert_response :success
      end

      it 'returns a valid XML response' do
        assert_xml @response.body
      end
    end
  end
end
