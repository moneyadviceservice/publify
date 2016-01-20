require 'fog'

class Admin::ResourcesController < Admin::BaseController
  cache_sweeper :blog_sweeper

  def index
    @r = Resource.new
    @resources = Resource.order('created_at DESC').page(params[:page]).per(this_blog.admin_display_elements)
  end

  def create
    if !params[:upload].blank?
      file = params[:upload][:filename]

      unless file.content_type
        mime = 'text/plain'
      else
        mime = file.content_type.chomp
      end
      @up = Resource.create(upload: file, mime: mime, created_at: Time.now)
      flash[:success] = I18n.t('admin.resources.create.success')
    else
      flash[:warning] = I18n.t('admin.resources.create.warning')
    end

    redirect_to admin_resources_path
  end

  def remove
    @resource = Resource.find(params[:id])
  end

  def destroy
    @resource = Resource.find(params[:id])
    @resource.destroy

    flash[:notice] = I18n.t('admin.resources.destroy.notice')
    redirect_to admin_resources_path
  end

end
