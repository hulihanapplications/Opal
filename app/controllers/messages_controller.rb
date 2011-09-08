class MessagesController < ApplicationController
  include ActionView::Helpers::TextHelper # include access to ActionView helpers

  before_filter :authenticate_user # make sure a user is logged in.
  
  before_filter :authenticate_message_owner, :only => [:delete_message, :unread_message, :read_message]
  protect_from_forgery :except => [:read_message, :unread_message, :delete_message]
  
  before_filter :enable_user_menu, :only => [:for_me] # show admin menu
  
  before_filter :authenticate_admin, :only => [:index, :for_user] # make sure logged in user is an admin   
  before_filter :enable_admin_menu, :only => [:index, :for_user] # show admin menu
 
  def index
    @setting[:meta_title] << UserMessage.model_name.human(:count => :other) 
    @messages = UserMessage.paginate :page => params[:page], :per_page => @setting[:items_per_page].to_i
  end

  def edit
  end

  def new
  end

  def for_user # messages for a particular user
    @user = User.find(params[:id])
    params[:type] ||= "unread" # set default lookup type
    @messages = Hash.new # hash to store messages
    @messages[:unread] = UserMessage.paginate :page => params[:page], :per_page => @setting[:items_per_page].to_i, :conditions => ["user_id = ? and to_user_id = ? and is_read = '0'", @user.id, @user.id ]
    @messages[:read] = UserMessage.paginate :page => params[:page], :per_page => @setting[:items_per_page].to_i, :conditions => ["user_id = ? and to_user_id = ? and is_read = '1'", @user.id, @user.id ]     
    @messages[:sent] = UserMessage.paginate :page => params[:page], :per_page => @setting[:items_per_page].to_i, :conditions => ["user_id = ? and from_user_id = ?", @user.id, @user.id]         
  end

  def for_me # messages for the logged in user.
    params[:type] ||= "unread" # set default lookup type
    @messages = Hash.new # hash to store messages
    @messages[:unread] = UserMessage.paginate :page => params[:page], :per_page => @setting[:items_per_page].to_i, :conditions => ["user_id = ? and to_user_id = ? and is_read = '0'", @logged_in_user.id, @logged_in_user.id ]
    @messages[:read] = UserMessage.paginate :page => params[:page], :per_page => @setting[:items_per_page].to_i, :conditions => ["user_id = ? and to_user_id = ? and is_read = '1'", @logged_in_user.id, @logged_in_user.id ]      
    @messages[:sent] = UserMessage.paginate :page => params[:page], :per_page => @setting[:items_per_page].to_i, :conditions => ["user_id = ? and from_user_id = ?", @logged_in_user.id, @logged_in_user.id]        
  end
  
  def delete_message
    @message = UserMessage.find(params[:id])
    if @message.destroy
      #render :nothing => true # show nothing
      flash[:success] =  t("notice.item_delete_success", :item => UserMessage.model_name.human)
    else 
      flash[:success] =  t("notice.item_delete_failure", :item => UserMessage.model_name.human) 
    end 
    
    if @logged_in_user.is_admin? # did an admin do this?
      redirect_to :action => "for_user", :type => params[:type], :id => @message.user_id # go the user's messages         
    else # not an admin, go back to user's messages 
      redirect_to :action => "for_me", :type => params[:type]        
    end
  end

  def read_message # mark message as read
    @message = UserMessage.find(params[:id])
    if @message.update_attribute(:is_read, "1")
      #render :nothing => true # show nothing
      flash[:success] =  t("notice.item_save_success", :item => UserMessage.model_name.human)
    else 
      flash[:success] =  t("notice.item_save_failure", :item => UserMessage.model_name.human) 
    end  
    
    if @logged_in_user.is_admin? # did an admin do this?
      redirect_to :action => "for_user", :type => params[:type], :id => @message.user_id # go the user's messages         
    else # not an admin, go back to user's messages 
      redirect_to :action => "for_me", :type => params[:type]  # go to my messages
    end
  end
  
  def unread_message # mark message as unread
    if @message.update_attribute(:is_read, "0")
       flash[:success] =  t("notice.item_save_success", :item => UserMessage.model_name.human) 
    else 
      flash[:success] =  t("notice.item_save_failure", :item => UserMessage.model_name.human) 
    end 

    if @logged_in_user.is_admin? # did an admin do this?
      redirect_to :action => "for_user", :type => params[:type], :id => @message.user_id # go the user's messages         
    else # not an admin, go back to user's messages 
      redirect_to :action => "for_me", :type => params[:type]        
    end  
  end
  
  def send_message     
    @user_to = User.find(params[:id])
    @message = UserMessage.new
    @message.from_user_id = @logged_in_user.id
    @message.to_user_id = @user_to.id      
    @message.user_id = @user_to.id      
    if params[:reply_to_message_id] # they are replying to another message
      @message_replying_to = UserMessage.find(params[:reply_to_message_id].to_i)
      @message.reply_to_message_id = @message_replying_to.id
      #@message.message = "Re: #{truncate(@message_replying_to.message, :length => 30)} -- \n\n" + params[:message] # Add a Re: [message_preview] tag to beginning of message
      @message.message = params[:message]      
    else # replying, just sending a regular message
      @message.message = params[:message]
    end
    
    if @message.save
      # Create Sent Message
      @sent_message = @message.clone
      @sent_message.user_id = @logged_in_user.id # the sending user gets to own this message.
      @sent_message.save      
      
      flash[:success] = t("notice.message_send_success", :item => UserMessage.model_name.human, :to => @user_to.username)  
    else 
      flash[:failure] = t("notice.message_send_failure", :item => UserMessage.model_name.human, :to => @user_to.username)  
    end 
    
    redirect_to :action => "for_me", :type => params[:type]        
  end

  

private

 def authenticate_message_owner # check to see if the logged in user can edit this message
    @message = UserMessage.find(params[:id])   
    if @message.user_id == @logged_in_user.id || @logged_in_user.is_admin? # does the logged in user own this message? 
      # proceed
    else 
      flash[:failure] = t("notice.invalid_permissions")    
      redirect_to :action => "for_me"
    end
 end
end
