feature 'Pictures page access' do
  background do
    create(:blog)
  end

  scenario 'when user is not logged in' do
    visit '/blog/admin/ckeditor/pictures'

    expect(current_path).to eq('/blog/accounts/login')
  end

  scenario 'when user is an admin' do
    sign_in(:as_admin)
    visit '/blog/admin/ckeditor/pictures'

    expect(current_path).to eq('/blog/admin/ckeditor/pictures')
  end

  scenario 'when user is a publisher' do
    sign_in(:as_publisher)
    visit '/blog/admin/ckeditor/pictures'

    expect(current_path).to eq('/blog/admin/ckeditor/pictures')
  end
end
