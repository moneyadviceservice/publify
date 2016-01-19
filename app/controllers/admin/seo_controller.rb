class Admin::SeoController < Admin::BaseController
  cache_sweeper :blog_sweeper
  before_filter :set_setting, only: [:index, :titles]

  def index
  end

  def update
    update_settings if request.post?
  rescue ActiveRecord::RecordInvalid
    render params[:from]
  end

  private

  def update_settings
    update_settings_with!(params[:setting])
    redirect_to action: params[:from]
  end

  def set_setting
    @setting = this_blog
  end
end
