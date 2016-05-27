Ckeditor.setup do |config|
  require 'ckeditor/orm/active_record'

  config.image_file_types = %w(jpg jpeg png gif tiff)
  config.attachment_file_types = %w(doc docx xls odt ods pdf)
  config.picture_model { Ckeditor::Picture }
  config.attachment_file_model { Ckeditor::AttachmentFile }
  config.default_per_page = 24
  config.assets_languages = %w(en uk)
  config.assets_plugins = %w(image)
  config.authorize_with do
    redirect_to main_app.accounts_path unless authorized?
  end
end

module Ckeditor
  class AssetResponse
    def success(relative_url_root = nil)
      if json?
        {
            json: { "uploaded" => 1, "fileName" => asset.filename, "url" => asset.url }.to_json
        }
      elsif ckeditor?
        {
            text: %Q"<script type='text/javascript'>
            window.parent.CKEDITOR.tools.callFunction(#{params[:CKEditorFuncNum]}, '#{asset_url(relative_url_root)}');
          </script>"
        }
      else
        {
            json: asset.to_json(only: [:id, :type])
        }
      end
    end

    private

    def asset_url(relative_url_root)
      url = Ckeditor::Utils.escape_single_quotes(asset.url_content)

      if URI(url).relative?
        "#{relative_url_root}#{url}"
      else
        url
      end
    end
  end
end
