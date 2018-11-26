feature 'Uploaded files access' do
  background do
    create(:blog)
  end

  scenario 'when user is not an admin' do
    visit '/blog/admin/ckeditor/attachment_files'

    expect(current_path).to eq('/blog/accounts/login')
  end

  scenario 'when user is an admin' do
    sign_in(:as_admin)
    visit '/blog/admin/ckeditor/attachment_files'

    expect(current_path).to eq('/blog/admin/ckeditor/attachment_files')
  end

  scenario 'when user is a publisher' do
    sign_in(:as_publisher)
    visit '/blog/admin/ckeditor/attachment_files'

    expect(current_path).to eq('/blog/admin/ckeditor/attachment_files')
  end

  scenario 'when user is a contributor' do
    sign_in(:as_publisher)
    visit '/blog/admin/ckeditor/attachment_files'

    expect(current_path).to eq('/blog/admin/ckeditor/attachment_files')
  end
end
