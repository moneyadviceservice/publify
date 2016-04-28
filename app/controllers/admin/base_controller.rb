class Admin::BaseController < ApplicationController
  cattr_accessor :look_for_migrations
  @@look_for_migrations = true
  layout 'administration'

  before_filter :login_required, except: [:login, :signup]
  before_filter :check_and_generate_secret_token, except: [:login, :signup, :migrate]

  private

  def parse_date_time(str)
    DateTime.strptime(str, '%B %e, %Y %I:%M %p GMT%z').utc
  rescue
    Time.parse(str).utc rescue nil
  end

  def update_settings_with!(settings_param)
    Blog.transaction do
      settings_param.each { |k, v| this_blog.send("#{k}=", v) }
      if this_blog.save
        flash[:success] = I18n.t('admin.settings.update.success')
      else
        flash[:error] = I18n.t('admin.settings.update.error', messages: this_blog.errors.full_messages.join(', '))
      end
    end
  end

  def check_and_generate_secret_token
    return if defined? $TESTING

    checker = Admin::TokenChecker.new
    return if checker.safe_token_in_use?

    begin
      checker.generate_token
      flash[:notice] = I18n.t('admin.base.restart_application')
    rescue
      flash[:error] = I18n.t('admin.base.cant_generate_secret', checker_file: checker.file)
    end
  end

end
