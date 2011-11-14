class GroupsController < ApplicationController
 before_filter :authenticate_admin # make sure logged in user is an admin   
 before_filter :enable_admin_menu # show admin menu 

   def index
        @groups = Group.paginate :page => params[:page], :per_page => 25, :order => "name ASC"
        @setting[:meta_title] << Group.model_name.human(:count => :other)
   end
   
    def create
      @group = Group.new(params[:group])
      if params[:is_admin] == "1"
        @group.is_admin = "1" # Make group an admin 
      end
      if @group.save # save successful
        flash[:success] = t("notice.item_create_success", :item => Group.model_name.human)        
        log(:target => @group,  :log_type => "create")
        redirect_to :action => 'index'
      else
        flash[:failure] = t("notice.item_create_failure", :item => Group.model_name.human)
        render :action => 'new'
      end
    end
  
   
   def update
      @group = Group.find(params[:id])
      flash[:notice] = ""
      if @group.update_attributes(params[:group])
        log(:target => @group,  :log_type => "update")
        flash[:success] = t("notice.item_save_success", :item => Group.model_name.human)
        redirect_to :action => "edit", :id => @group.id
      else
        flash[:failure] = t("notice.item_save_failure", :item => Group.model_name.human)
        render :action => "edit"
      end
   end

   def update_plugin_permissions
      @group = Group.find(params[:id])
 
       # reset permissions: erase all, then re-add 
       for item in @group.group_plugin_permissions
         item.destroy # destroy permission
       end
 
       if params[:plugin_permission] # add permissions if any were checked
        params[:plugin_permission].each do |key, value|
            permissions_hash = Hash.new # create a new hash
            # initalize a hash containing values for this permission record
            permissions_hash[:can_create] = value[:can_create]  ||= "0" # set flag default to 0(off)
            permissions_hash[:can_read] =   value[:can_read]    ||= "0" # set flag default to 0(off)
            permissions_hash[:can_update] = value[:can_update]  ||= "0" # set flag default to 0(off)
            permissions_hash[:can_delete] = value[:can_delete]  ||= "0" # set flag default to 0(off)
            permissions_hash[:requires_approval] =  value[:requires_approval] ||= "0" # set flag default to 0(off)
            
            permissions_hash[:group_id] = @group.id 
            permissions_hash[:plugin_id] = key # set the plugin id      
            GroupPluginPermission.create(permissions_hash) # create the record
        end
        log(:log_type => "create", :log => t("log.item_save", :item => GroupPluginPermission.model_name.human, :name => @group.name))
      end
      flash[:success] = t("notice.save_success")            
      redirect_to :action => "edit", :id => @group.id
   end  
  
   def delete 
     if params[:id].to_i == @logged_in_user.group_id.to_i
       flash[:failure] = t("notice.delete_own_group_failure")
     else
       @group = Group.find(params[:id])
       if @group.is_deletable?
         log(:target => @group,  :log_type => "destroy")
         flash[:success] = t("notice.item_delete_success", :item => Group.model_name.human) 
         @group.destroy
       else
         flash[:failure] = t("notice.item_delete_failure", :item => Group.model_name.human)         
       end 
     end
     redirect_to :action => 'index'
   end


  def edit
    @group = Group.find(params[:id])
    @plugins = Plugin.find(:all, :order => "order_number ASC")   
  end

  def new
    @group = Group.new
  end


end
