class Admin::SettingsController < Admin::BaseController
  cache_sweeper :blog_sweeper

  def index
    if this_blog.base_url.blank?
      this_blog.base_url = blog_base_url
    end
    load_settings
  end

  def write; load_settings end
  def feedback; load_settings end
  def display; load_settings end

  def update
    if request.post?
      update_settings_with!(params[:setting])
      redirect_to action: params[:from]
    end
  rescue ActiveRecord::RecordInvalid
    render params[:from]
  end

end
