# coding: utf-8
require 'base64'

class Admin::PagesController < Admin::BaseController

  before_filter :set_images, only: [:new, :edit]

  layout :get_layout
  cache_sweeper :blog_sweeper

  def index
    @search = params[:search] ? params[:search] : {}
    @pages = Page.search_with(@search).page(params[:page]).per(this_blog.admin_display_elements)
  end

  def new
    @page = Page.new((params[:page].permit! if params[:page]))
    @page.user_id = current_user.id
    @page.text_filter ||= default_textfilter
    @page.published = true unless params[:page].present?
  end

  def create
    @page = Page.new((params[:page].permit! if params[:page]))
    @page.user_id = current_user.id
    @page.text_filter ||= default_textfilter
    @page.published = true unless params[:page].present?
    @page.published_at = Time.now

    if @page.save
      flash[:success] = I18n.t('admin.pages.create.success')
      redirect_to action: 'index'
    else
      render action: :new
    end
  end

  def edit
    @page = Page.find(params[:id])
    @page.attributes = params[:page].permit! if params[:page]
    @page.text_filter ||= default_textfilter
  end

  def update
    @page = Page.find(params[:id])
    @page.attributes = params[:page].permit! if params[:page]
    @page.text_filter ||= default_textfilter

    if @page.save
      flash[:success] = I18n.t('admin.pages.update.success')
      redirect_to admin_pages_path
    else
      render action: :edit
    end
  end

  def destroy
    Page.find(params[:id]).destroy
    flash[:notice] = I18n.t('admin.pages.destroy.successfully_deleted')
    redirect_to admin_pages_path
  end

  def remove
    @page = Page.find(params[:id])
  end

  private

  def default_textfilter
    current_user.text_filter || blog.text_filter
  end

  def set_images
    @images = Resource.images.by_created_at.page(1).per(10)
  end

  def get_layout
    case action_name
    when 'new', 'edit', 'create'
      'editor'
    when 'show'
      nil
    else
      'administration'
    end
  end

end
