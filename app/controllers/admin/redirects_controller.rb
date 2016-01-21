class Admin::RedirectsController < Admin::BaseController
  def index
    redirect_to new_admin_redirect_path
  end
  
  def new
    @redirect = Redirect.new
    @redirects = find_redirects
  end

  def create
    @redirect = Redirect.new(params[:redirect].permit!)
    @redirect.from_path = @redirect.shorten
    
    if @redirect.save
      flash[:notice] = I18n.t('admin.redirects.create.successfully_saved')
      redirect_to action: 'index'
    else
      @redirects = find_redirects
      flash.now[:error] = I18n.t('admin.redirects.create.unsuccessfully_saved')
      render action: :new
    end
  end

  def edit
    @redirect = Redirect.find(params[:id])
    @redirects = find_redirects
  end

  def update
    @redirect = Redirect.find(params[:id])

    if @redirect.update_attributes(params[:redirect].permit!)
      flash[:notice] = I18n.t('admin.redirects.update.successfully_saved')
      redirect_to admin_redirects_path
    else
      @redirects = find_redirects
      flash.now[:error] = I18n.t('admin.redirects.update.unsuccessfully_saved')
      render action: :edit
    end
  end
  
  def remove
    @redirect = Redirect.find(params[:id])
  end

  def destroy
    Redirect.find(params[:id]).destroy
    flash[:notice] = I18n.t('admin.redirects.destroy.successfully_deleted')
    redirect_to admin_redirects_path
  end

  private

  def find_redirects
    Redirect.where('origin is null').order('id desc').page(params[:page]).per(this_blog.admin_display_elements)
  end
end
