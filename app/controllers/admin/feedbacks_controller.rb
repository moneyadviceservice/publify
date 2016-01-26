class Admin::FeedbacksController < Admin::BaseController
  cache_sweeper :blog_sweeper

  def index
    if params[:article_id]
      @article = Article.find(params[:article_id])
      scoped_feedback = @article.comments
    else
      scoped_feedback = Feedback
    end

    scoped_feedback = scoped_feedback.unscope(:order).order(order_sql)

    if params[:only].present?
      scoped_feedback = scoped_feedback.send(params[:only])
    end

    if params[:page].blank? || params[:page] == '0'
      params.delete(:page)
    end

    @feedback = scoped_feedback.paginated(params[:page], this_blog.admin_display_elements)
  end

  def edit
    @comment = Comment.find(params[:id])
    redirect_to admin_feedbacks_path if !@comment.article.access_by?(current_user)
  end

  def update
    @comment = Comment.find(params[:id])
    return redirect_to admin_feedbacks_path if !@comment.article.access_by?(current_user)

    if @comment.update_attributes(params[:comment].permit!)
      flash[:success] = I18n.t('admin.feedbacks.update.success')
      redirect_to admin_feedbacks_path(article_id: @comment.article)
    else
      render action: :edit
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    return if @comment.article.user != current_user && !current_user.admin?

    @comment.destroy
    flash[:notice] = I18n.t('admin.feedbacks.destroy.successfully_deleted')
    redirect_to admin_feedbacks_path(article_id: @comment.article)
  end

  def remove
    @comment = Comment.find(params[:id])
    return if @comment.article.user != current_user && !current_user.admin?
  end

  def change_state
    return if !request.xhr?

    @feedback = Feedback.find(params[:id])
    template = @feedback.change_state!

    respond_to do |format|
      if params[:context] != 'listing'
        @comments = Comment.last_published
        page.replace_html('commentList', partial: 'admin/dashboard/comment')
      else
        if template == 'ham'
          format.js { render 'ham' }
        else
          format.js { render 'spam' }
        end
      end
    end
  end

  def bulkops
    ids = (params[:feedback_check] || {}).keys.map(&:to_i)
    items = Feedback.find(ids)
    @unexpired = true

    bulkop = (params[:bulkop_top] || {}).empty? ? params[:bulkop_bottom] : params[:bulkop_top]

    case bulkop
    when 'Delete Checked Items'
      count = 0
      ids.each do |id|
        count += Feedback.delete(id)
      end
      flash[:success] = I18n.t('admin.feedbacks.bulkops.success_deleted', count: count)

      items.each do |i|
        i.invalidates_cache? or next
        flush_cache
        return
      end
    when 'Mark Checked Items as Ham'
      update_feedback(items, :mark_as_ham!)
      flash[:success] =  I18n.t('admin.feedbacks.bulkops.success_mark_as_ham', count: ids.size)
    when 'Mark Checked Items as Spam'
      update_feedback(items, :mark_as_spam!)
      flash[:success] =  I18n.t('admin.feedbacks.bulkops.success_mark_as_spam', count: ids.size)
    when 'Delete all spam'
      Feedback.delete_all(['state = ?', 'spam'])
      flash[:success] = I18n.t('admin.feedbacks.bulkops.success_deleted_spam')
    else
      flash[:error] = I18n.t('admin.feedbacks.bulkops.error')
    end

    if params[:article_id]
      redirect_to admin_feedbacks_path(article_id: params[:article_id], confirmed: params[:confirmed], published: params[:published])
    else
      redirect_to admin_feedbacks_path(page: params[:page], search: params[:search], confirmed: params[:confirmed], published: params[:published])
    end
  end

  protected

  def sort_order
    if params[:sort_order].present?
      params[:sort_order]
    else
      if sort_by == 'commented_at'
        'desc'
      else
        'asc'
      end
    end
  end
  helper_method :sort_order

  def sort_by
    if params[:sort_by].present?
      params[:sort_by]
    else
      'commented_at'
    end
  end
  helper_method :sort_by

  def order_sql
    order_sql = case sort_by
                  when 'commented_at'
                    'created_at'
                  when 'commenter'
                    'author'
                end

    case sort_order
      when 'asc'
        order_sql + ' ASC'
      when 'desc'
        order_sql + ' DESC'
    end
  end

  def update_feedback(items, method)
    items.each do |value|
      value.send(method)
      @unexpired && value.invalidates_cache? or next
      flush_cache
    end
  end

  def flush_cache
    @unexpired = false
    PageCache.sweep_all
  end

end
