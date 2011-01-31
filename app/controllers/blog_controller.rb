class BlogController < ApplicationController
  def index
    @pages = Page.all.blog.published.newest_first.paginate :page => params[:page], :per_page => 5
  end

  def rss 
    @pages = Page.all.blog.published.newest_first.paginate :page => params[:page], :per_page => 10
    render :layout => false
  end

  def post
    @page = Page.find(params[:id])
    @page_comments = PageComment.paginate :page => params[:page], :per_page => 25, :conditions => ["page_id = ? and is_approved = ?", @page.id, "1"], :order => "created_at DESC"    
    if @page.published || @logged_in_user.is_admin? # make sure this is a published page they're going to
      # proceed
      @setting[:meta_title] << @page.title
    else
      flash[:error] = t("notice.not_visible")      
      redirect_to :action => "index", :controller => "browse"
    end       
  end

  def archive
   # Set Range Defaults
   params[:month] ||= Time.now.strftime("%m") # default month
   params[:year] ||= Time.now.strftime("%Y") # default year 
   params[:day] ||= Time.now.strftime("%d") # default day    
   @date = Time.parse("#{params[:year]}/#{params[:month]}/") # date to search(by month)
   @pages = Page.all.blog.published.newest_first.paginate :page => params[:page], :per_page => 5, :conditions => ["created_at > ? and created_at < ?", @date.beginning_of_month, @date.end_of_month]
  end  
  
end
