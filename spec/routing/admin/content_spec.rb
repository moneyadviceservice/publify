require 'rails_helper'

# TODO: Clean out non-resourceful routes
describe 'Admin::ContentController routing', type: :routing do
  it 'routes #new' do
    expect(get: '/admin/content/new').to route_to(controller: 'admin/content',
                                                    action: 'new', id: nil)
  end

  it 'routes #autosave' do
    expect(post: '/admin/content/autosave').to route_to(controller: 'admin/content', action: 'autosave', id: nil)
  end

  it 'routes #auto_complete_for_article_keywords' do
    expect(get: '/admin/content/auto_complete_for_article_keywords').to route_to(controller: 'admin/content',
                                                                                   action: 'auto_complete_for_article_keywords', id: nil)
  end
end
