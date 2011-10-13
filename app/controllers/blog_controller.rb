class BlogController < ApplicationController 
  def index
    @pages = Page.all.blog.published.newest_first.paginate(:page => params[:page], :per_page => 5)
  end

  def rss 
    @pages = Page.all.blog.published.newest_first.paginate(:page => params[:page], :per_page => 10)
    render :layout => false
  end

  def post
    @page = Page.find(params[:id])
    if @page.published || @logged_in_user.is_admin? # make sure this is a published page they're going to
      # proceed
      @setting[:meta_title] << @page.title
    else
      flash[:error] = t("notice.not_visible")      
      redirect_to :action => "index", :controller => "browse"
    end       
  end

  def archive
   @date = Time.mktime(params[:year].blank? ? 10.years.ago.strftime("%Y") : params[:year], params[:month], params[:day]) 
   # Compute Time Range based on parameters, should we look to beginning of day, month, or year? 
   range_start = !params[:day].blank? ? @date.beginning_of_day : (!params[:month].blank? ? @date.beginning_of_month : !params[:year].blank? ? @date.beginning_of_year : 10.years.ago.beginning_of_year) 
   range_end =  !params[:day].blank? ? @date.end_of_day : (!params[:month].blank? ? @date.end_of_month : !params[:year].blank? ? @date.end_of_year : Time.now)    
   @pages = Page.all.blog.published.newest_first.paginate :page => params[:page], :per_page => 5, :conditions => ["created_at > ? and created_at < ?", range_start, range_end]
  end  
  
end
