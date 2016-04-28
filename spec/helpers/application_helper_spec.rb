# coding: utf-8
class TestBrokenSidebar < Sidebar
  description 'Invalid test sidebar'
  def parse_request(_contents, _request_params)
    raise "I'm b0rked!"
  end
end

describe ApplicationHelper, type: :helper do
  context 'With a simple blog' do
    let!(:blog) { create(:blog) }

    describe 'stop_index_robots?' do
      subject { helper.stop_index_robots?(blog) }

      context 'default' do
        it { expect(subject).to be_falsey }
      end

      context 'with year:2010' do
        before(:each) { params[:year] = 2010 }
        it { expect(subject).to be_truthy }
      end

      context 'with page:2' do
        before(:each) { params[:page] = 2 }
        it { expect(subject).to be_truthy }
      end

      context 'for the tags controller' do
        before(:each) { allow(helper).to receive(:controller_name).and_return('tags') }

        context 'with unindex_tags set in blog' do
          before(:each) { expect(blog).to receive(:unindex_tags).and_return(true) }
          it { expect(subject).to be_truthy }
        end

        context 'with unindex_tags set in blog' do
          before(:each) { expect(blog).to receive(:unindex_tags).and_return(false) }
          it { expect(subject).to be_falsey }
        end
      end

      context 'for the categories controller' do
        before(:each) { allow(helper).to receive(:controller_name).and_return('categories') }

        context 'with unindex_tags set in blog' do
          before(:each) { expect(blog).to receive(:unindex_categories).and_return(true) }
          it { expect(subject).to be_truthy }
        end

        context 'with unindex_tags set in blog' do
          before(:each) { expect(blog).to receive(:unindex_categories).and_return(false) }
          it { expect(subject).to be_falsey }
        end
      end
    end

    describe '#get_reply_context_url' do
      it "returns a link to the reply's URL if given" do
        reply = {
          'user' => {
            'name' => 'truc',
            'entities' => { 'url' => { 'urls' => [{ 'expanded_url' => 'an url' }] } }
          }
        }
        expect(get_reply_context_url(reply)).to eq "<a href=\"an url\">truc</a>"
      end

      it "returns a link to the reply's user if no URL is given" do
        reply = { 'user' => { 'name' => 'truc', 'entities' => {} } }
        expect(get_reply_context_url(reply))
          .to eq "<a href=\"https://twitter.com/truc\">truc</a>"
      end
    end

    describe '#get_reply_context_twitter_link' do
      let(:reply) { { 'id_str' => '123456789',
                      'created_at' => 'Thu Jan 23 13:47:00 +0000 2014',
                      'user' => {
                        'screen_name' => 'a_screen_name',
                        'entities' => { 'url' => { 'urls' => [{ 'expanded_url' => 'an url' }] } }
                      } } }
      it 'returns a link with the creation date' do
        begin
          timezone = Time.zone
          Time.zone = 'UTC'

          expect(get_reply_context_twitter_link(reply))
            .to eq "<a href=\"https://twitter.com/a_screen_name/status/123456789\">January 23 2014</a>"
        ensure
          Time.zone = timezone
        end
      end

      it 'displays creation date in the current time zone' do
        begin
          timezone = Time.zone
          Time.zone = 'Tokyo'

          expect(get_reply_context_twitter_link(reply))
            .to eq "<a href=\"https://twitter.com/a_screen_name/status/123456789\">January 23 2014</a>"
        ensure
          Time.zone = timezone
        end
      end
    end

    context 'SidebarHelper' do
      # XXX: Ugh. Needed to break tight coupling :-(.
      def render_to_string(options)
        "Rendered #{options[:file] || options[:partial]}."
      end

      describe '#render_sidebars' do
        describe 'with an invalid sidebar' do
          before do
            TestBrokenSidebar.new.save
          end

          def logger
            fake_logger = double('fake logger')
            expect(fake_logger).to receive(:error)
            fake_logger
          end

          it 'should return a friendly error message' do
            expect(render_sidebars).to match(/It seems something went wrong/)
          end
        end

        describe 'with a valid sidebar' do
          before do
            Sidebar.new.save
          end

          it 'should render the sidebar' do
            expect(render_sidebars).to match(/Rendered/)
          end
        end
      end
    end
  end

  describe '#display_date' do

    ['%d/%m/%y', '%m/%m/%y', '%d %b %Y', '%b %d %Y', '%I:%M%p', '%H:%M', '%Hh%M'].each do |spec|
      it "use #{spec} format from blog to render date" do
        create(:blog, date_format: spec)
        article = build(:article)
        expect(display_date(article.published_at)).to eq(article.published_at.strftime(spec))
      end
    end
  end

end
