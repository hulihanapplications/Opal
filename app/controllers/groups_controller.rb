class GroupsController < ApplicationController
 before_filter :authenticate_admin # make sure logged in user is an admin   
 before_filter :enable_admin_menu # show admin menu 

   def index
        @groups = Group.paginate :page => params[:page], :per_page => 25, :order => "name ASC"
        @setting[:meta_title] = Group.human_name + " - " + t("section.title.admin").capitalize + " - " + @setting[:meta_title]
   end
   
    def create
      @group = Group.new(params[:group])
      if params[:is_admin] == "1"
        @group.is_admin = "1" # Make group an admin 
      end
      if @group.save # save successful
        flash[:success] = t("notice.object_create_success", :object => Group.human_name)        
        Log.create(:user_id => @logged_in_user.id, :log_type => "create", :log =>  t("log.object_create", :object => Group.human_name, :name => @group.name))
        redirect_to :action => 'index'
      else
        flash[:failure] = t("notice.object_create_failure", :object => Group.human_name)
        render :action => 'new'
      end
    end
  
   
   def update
      @group = Group.find(params[:id])
      flash[:notice] = ""
      if @group.update_attributes(params[:group])
        Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log => t("log.object_save", :object => Group.human_name, :name => @group.name))
        flash[:success] = t("notice.object_save_success", :object => Group.human_name)
        redirect_to :action => "edit", :id => @group.id
      else
        flash[:failure] = t("notice.object_save_failure", :object => Group.human_name)
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
        Log.create(:user_id => @logged_in_user.id, :log_type => "create", :log => t("log.object_save", :object => GroupPluginPermission.human_name, :name => @group.name))
      end
      flash[:success] = t("notice.object_save_success", :object => GroupPluginPermission.human_name.pluralize)            
      redirect_to :action => "edit", :id => @group.id
   end  
  
   def delete 
     if params[:id].to_i == @logged_in_user.group_id.to_i
       flash[:failure] = t("notice.delete_own_group_failure")
     else
       @group = Group.find(params[:id])
       if @group.is_deletable?
         Log.create(:user_id => @logged_in_user.id, :log_type => "delete", :log => t("log.object_delete", :object => Group.human_name, :name => @group.name))
         flash[:success] = t("notice.object_delete_success", :object => Group.human_name) 
         @group.destroy
       else
         flash[:failure] = t("notice.object_delete_failure", :object => Group.human_name)         
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
