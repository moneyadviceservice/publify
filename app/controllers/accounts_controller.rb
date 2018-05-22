class AccountsController < ApplicationController

  before_filter :redirect_if_already_logged_in, only: :login

  def login
    return unless request.post?
    self.current_user = User.authenticate(params[:user][:login], params[:user][:password])

    if logged_in?
      if params[:remember_me] == '1'
        current_user.remember_me unless current_user.remember_token?
        cookies[:auth_token] = {
          value: current_user.remember_token,
          expires: current_user.remember_token_expires_at,
          httponly: true # Help prevent auth_token theft.
        }
      end
      add_to_cookies(:publify_user_profile, current_user.profile_label, '/')
      current_user.update_connection_time

      flash[:success] = t('accounts.login.success')
      redirect_back_or_default
    else
      flash[:error] = t('accounts.login.error')
      @login = params[:user][:login]
    end
  end

  def recover_password
    return unless request.post?
    @user = User.where(login: params[:user][:login]).first ||
            User.where(email: params[:user][:login]).first

    if @user
      @user.generate_password!
      @user.save
      flash[:notice] = t('accounts.recover_password.notice')
      redirect_to login_path
    else
      flash[:error] = t('accounts.recover_password.error')
    end
  end

  def logout
    flash[:notice] = t('accounts.logout.notice')
    current_user.forget_me
    self.current_user = nil
    session[:user_id] = nil
    cookies.delete :auth_token
    cookies.delete :publify_user_profile
    redirect_to login_path
  end

  private

  def redirect_if_already_logged_in
    if session[:user_id] && session[:user_id] == current_user.id
      redirect_back_or_default
    end
  end

  def redirect_back_or_default
    redirect_to(session[:return_to] || admin_dashboard_path)
    session[:return_to] = nil
  end
end
