# coding: utf-8
describe AmpArticlesController, 'base', type: :controller do
  let!(:blog) { create(:blog) }
  let(:params) { {} }

  describe '#show' do
    let!(:article) { create(:article, permalink: 'second-blog-article', published_at: '2004-04-01 02:00:00', updated_at: '2004-04-01 02:00:00', created_at: '2004-04-01 02:00:00', supports_amp: supports_amp) }
    before(:each) do
      get :show, { from: "#{article.permalink}" }.merge(params)
    end

    context 'it supports amp' do
      let(:supports_amp) { true }

      it 'should render template read to article' do
        expect(response).to render_template('articles/amp/show')
      end

      it 'should assign article1 to @article' do
        expect(assigns(:article)).to eq(article)
      end
    end

    context 'it does not support amp' do
      let(:supports_amp) { false }

      it 'returns a 302' do
        expect(response.status).to eql(302)
      end

      context 'has no_redirect param' do
        let(:params) { { no_redirect: true } }

        it 'should render template read to article' do
          expect(response).to render_template('articles/amp/show')
        end

        it 'should assign article1 to @article' do
          expect(assigns(:article)).to eq(article)
        end
      end
    end
  end
end
