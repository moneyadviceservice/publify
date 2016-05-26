describe 'Admin::ContentController routing', type: :routing do
  it 'routes #new' do
    expect(get: '/admin/articles/new').to route_to(controller: 'admin/contents', action: 'new')
  end
end
