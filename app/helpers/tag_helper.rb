module TagHelper
  def tagged_as_heading
    t(".#{request.env['PATH_INFO'].split('/')[1]}.articles_tagged_as")
  end
end
