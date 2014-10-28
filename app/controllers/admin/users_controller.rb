class Admin::UsersController < Admin::BaseController
  cache_sweeper :blog_sweeper

  def index
    @users = User.order('login asc').page(params[:page]).per(this_blog.admin_display_elements)
  end

  def new
    @user = User.new
    @user.attributes = params[:user].permit! if params[:user]
    @user.text_filter = TextFilter.find_by_name(this_blog.text_filter)
    setup_profiles
    @user.name = @user.login
    if request.post? && @user.save
      flash[:success] = I18n.t('admin.users.new.success')
      redirect_to action: 'index'
    end
  end

  def edit
    @user = params[:id] ? User.find_by_id(params[:id]) : current_user

    setup_profiles
    @user.attributes = params[:user].permit! if params[:user]
    if request.post? && @user.save
      if @user.id = current_user.id
        current_user = @user
      end
      flash[:success] = I18n.t('admin.users.new.success')
      redirect_to action: 'index'
    end
  end

  def destroy
    @record = User.find(params[:id])
    return(render 'admin/shared/destroy') unless request.post?

    @record.destroy if User.where('profile_id = ? and id != ?', Profile.find_by_label('admin'), @record.id).count > 1
    redirect_to action: 'index'
  end

  private

  def setup_profiles
    @profiles = Profile.order('id')
  end
end
