class PagesController < ApplicationController
  before_filter :authenticate_admin, :except => [:create_page_comment, :redirect_to_page, :page, :view, :send_contact_us, :show] # make sure logged in user is an admin    
  before_filter :enable_admin_menu, :except => [:view, :send_contact_us, :show]# show admin menu 
  before_filter :uses_tiny_mce, :only => [:new, :create, :edit, :update, :destroy]  # which actions to load tiny_mce, TinyMCE Config is done in Layout. 
  before_filter :check_humanizer_answer, :only => [:send_contact_us]
  before_filter :find_page, :only => [:page, :view, :edit, :update, :delete, :show]
  before_filter(:only => [:view, :page, :show]) {|c| can?(@page, @logged_in_user, :read)} 
  
  
  def index
    @setting[:meta_title] << Page.model_name.human(:count => :other)
    params[:type] ||= "public"
    if params[:type].downcase == "public"
      @pages = Page.all.root.public.in_order
    elsif params[:type].downcase == "blog"
      @pages = Page.all.root.blog.newest_first
    elsif  params[:type].downcase == "system"
      @pages = Page.all.root.system.in_order
    else # unknown page type
      @pages = Page.all.root.public.in_order
    end
    @setting[:ui] = true
  end
  
  def create
    @page = Page.new(params[:page])
    @page.user_id = @logged_in_user.id
    if @page.save
      log(:log_type => "create", :target => @page)
      flash[:success] = t("notice.item_create_success", :item => Page.model_name.human)
      redirect_to :action => 'index', :type => @page.page_type.capitalize   
    else
      flash[:failure] = t("notice.item_create_failure", :item => Page.model_name.human)
      params[:type] = @page.page_type.capitalize      
      render :action => "new"
    end
  end
 
  def update
    if @page.update_attributes(params[:page]) 
      flash[:success] = t("notice.item_save_success", :item => Page.model_name.human)
      log(:log_type => "update", :target => @page)
      redirect_to :action => 'edit', :id => @page.id, :type => @page.page_type.capitalize  
    else
      flash[:failure] = t("notice.item_save_failure", :item => Page.model_name.human)
      render :action => "edit"
    end
  end
 
  def delete
    if @page.is_system_page? # Can't delete system pages
      flash[:failure] = t("notice.invalid_permissions")
    else 
      if @page.destroy 
        log(:log_type => "destroy", :target => @page)
        flash[:success] = t("notice.item_delete_success", :item => Page.model_name.human)
      end
    end
    redirect_to :action => 'index', :type => @page.page_type.capitalize     
  end  
 
  def new
    @page = Page.new
    params[:type] ||= "Public"
    @page.page_type = params[:type].downcase
    if params[:id]
      @page.page_id = params[:id].to_i
    end
  end
  
  def edit
    params[:type] = @page.page_type.capitalize
  end
  
  def page # Master Page Router 
    if @page.redirect # redirect? 
      redirect_to @page.redirect_url 
    else # don't redirect, go to page.
      if @page.page_type == "blog" # go to blog page
        redirect_to :action => "post", :controller => "blog", :id => @page
      else # public page 
          redirect_to :action => "view", :id => @page
      end      
    end
  end

  def view
    redirect_to @page.redirect_url if @page.redirect && !@page.redirect_url.blank?
    @setting[:meta_title] << @page.description if !@page.description.blank?
    @setting[:meta_title] << @page.title 
    @comments = PluginComment.record(@page).paginate(:page => params[:page], :per_page => 25).approved
  end 

  def show
    view
    render "view"
  end 

  def send_contact_us
   if !Cregexp.match(params[:email], :email)# validate email
     flash[:failure] = "#{t("notice.invalid_email")}" #print out any errors!
   else # email okay
    #  def contact_us_email(recipient, from = "noemailset@none.com", name = "No Name Set", subject = "No Subject Set", message = "No Message Set", ip = "", display = "plain") 
    # Send Email
    Emailer.contact_us_email(params[:email], params[:name], t("email.subject.contact_us", :site_title => @setting[:title], :from => params[:name]), params[:phone], params[:message], request.env['REMOTE_ADDR']).deliver
    flash[:success] = "#{t("notice.contact_thanks", :name => params[:name])}" #print out any errors!
   end
   redirect_to :action => "index", :controller => "browse"
  end  
  
  def update_order
    msg = String.new
    params[:ids].each_with_index do |id, position|
      page = Page.find(id) 
      page.update_attribute(:order_number, position)
    end
     log(:log_type => "system", :log => t("log.item_update", :item => Page.model_name.human, :name => Page.human_attribute_name(:order_number)))
     render :text => "<div class=\"notice\"><div class=\"success\">#{t("notice.save_success")}</div></div>"
  end
  
private
  def find_page
    @page = Page.find(params[:id])   
  rescue ActiveRecord::RecordNotFound
    @page = Page.find_by_slug(params[:id])   
  ensure
    @record = @page
  end 
end
