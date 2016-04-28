class CommentsController < ApplicationController

  layout :pick_layout

  def index
    @comments = Feedback.where(published: true).order('created_at ASC').limit(this_blog.per_page(params[:format]))

    respond_to do |format|
      format.atom
      format.rss
    end
  end

  def create
    @article = Article.find(params[:article_id])
    @comment = @article.with_options(new_comment_defaults) do |art|
      art.add_comment(params[:comment].slice(:body, :author, :email, :url))
    end

    unless current_user.nil? or session[:user_id].nil?
      # maybe useless, but who knows ?
      if current_user.id == session[:user_id]
        @comment.user_id = current_user.id
      end
    end

    session[:author] = @comment.author  if @comment.author.present?
    session[:email] = @comment.email if @comment.email.present?

    if recaptcha_ok_for?(@comment)  && @comment.save
      redirect_to article_path(@article.permalink, anchor: "comment-#{@comment.id}")
    else
      @page_title = @article.title_meta_tag.present? ? @article.title_meta_tag : @article.title
      @description = @article.description_meta_tag
      @keywords = @article.tags.map { |g| g.name }.join(', ')

      render "articles/#{@article.post_type}"
    end

  end

  protected

  def recaptcha_ok_for? comment
    use_recaptcha = Blog.default.settings['use_recaptcha']
    ((use_recaptcha && verify_recaptcha(model: comment)) || !use_recaptcha)
  end

  def new_comment_defaults
    { ip: request.remote_ip,
      author: 'Anonymous',
      published: true,
      user: @current_user,
      user_agent: request.env['HTTP_USER_AGENT'],
      referrer: request.env['HTTP_REFERER'],
      permalink: article_url(@article.permalink) }.stringify_keys
  end

  def set_headers
    headers['Content-Type'] = 'text/html; charset=utf-8'
  end

  def get_article
    @article = Article.find(params[:article_id])
  end

  def pick_layout
    request.format.html? ? 'default': false
  end
end
