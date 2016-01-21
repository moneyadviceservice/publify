class Admin::SettingsController < Admin::BaseController
  cache_sweeper :blog_sweeper

  def general
    @setting = this_blog
  end

  def write
    @setting = this_blog
  end

  def feedback
    @setting = this_blog
  end

  def display
    @setting = this_blog
  end

  def seo
    @setting = this_blog
  end

  def titles
    @setting = this_blog
  end

  def update
    update_settings_with!(params[:setting])
    redirect_to :back
  end

end
