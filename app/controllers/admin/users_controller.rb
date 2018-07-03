class Admin::UsersController < Admin::BaseController
  cache_sweeper :blog_sweeper

  def index
    @users = User.order(:id).page(params[:page]).per(this_blog.admin_display_elements)
  end

  def new
    @user = User.new
    @profiles = Profile.order('id')
  end

  def create
    @user = User.new(params[:user].permit!)
    @user.text_filter = TextFilter.find_by_name(this_blog.text_filter)
    @user.name = @user.login

    if @user.save
      flash[:success] = I18n.t('admin.users.create.success')
      redirect_to admin_users_path
    else
      @profiles = Profile.order('id')
      render action: :new
    end
  end

  def edit
    @user = User.find(params[:id])
    @profiles = Profile.order('id')
  end

  def update
    @user = User.find(params[:id])

    if @user.update_attributes(params[:user].permit!)
      flash[:success] = I18n.t('admin.users.update.success')
      redirect_to admin_users_path
    else
      @profiles = Profile.order('id')
      render action: :edit
    end
  end

  def remove
    @record = User.find(params[:id])
    return if !current_user.admin? && @record != current_user
  end

  def destroy
    @record = User.find(params[:id])
    return if !current_user.admin? && @record != current_user

    @record.destroy
    redirect_to admin_users_path
  end

end
