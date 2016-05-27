require 'ckeditor'

class Ckeditor::AssetResponse
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
