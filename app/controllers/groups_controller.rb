class GroupsController < ApplicationController
 before_filter :authenticate_admin # make sure logged in user is an admin   
 before_filter :enable_admin_menu # show admin menu 

   def index
        @groups = Group.paginate :page => params[:page], :per_page => 25, :order => "name ASC"
        @setting[:meta_title] = "Groups - Admin - "+ @setting[:meta_title]
   end
   
    def create
      @group = Group.new(params[:group])
      if params[:is_admin] == "1"
        @group.is_admin = "1" # Make group an admin 
      end
      if @group.save # save successful
        flash[:notice] = "<div class=\"flash_success\">Group was successfully created.</div>"
        
        Log.create(:user_id => @logged_in_user.id, :log_type => "create", :log => "Created the #{@group.name} group.")
      else
        flash[:notice] = "<div class=\"flash_failure\">Group could not be created! Here's why.<br>"
         @group.errors.each do |key,value|
          flash[:notice] << "<b>#{key}</b>...#{value}</font><br>" #print out any errors!
         end
        flash[:notice] << "</div>"
      end
      redirect_to :action => 'index'
    end
  
   
   def update
      @group = Group.find(params[:id])
      flash[:notice] = ""
      if @group.update_attributes(params[:group])
        Log.create(:user_id => @logged_in_user.id, :log_type => "update", :log => "Updated the #{@group.name} group.")
        flash[:notice] = "<div class=\"flash_success\">Group was successfully updated.</div>"
      else
        flash[:notice] = "<div class=\"flash_failure\">Group could not be updated!  Here's why.<br>"
         @group.errors.each do |key,value|
          flash[:notice] << "<b>#{key}</b>...#{value}</font><br>" #print out any errors!
         end
        flash[:notice] << "</div>"
      end
      redirect_to :action => "edit", :id => @group.id
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
        Log.create(:user_id => @logged_in_user.id, :log_type => "create", :log => "Changed the #{@group.name} group's plugin permissions.")
        flash[:notice] = "<div class=\"flash_success\">Plugin Permissions updated!</div>"      
      end
      
      redirect_to :action => "edit", :id => @group.id
   end  
  
   def delete 
     if params[:id].to_i == @logged_in_user.group_id.to_i
       flash[:notice] = "<div class=\"flash_failure\">Sorry, You can't delete the your own group.</div>"
     else
       @group = Group.find(params[:id])
       if @group.is_deletable?
         Log.create(:user_id => @logged_in_user.id, :log_type => "delete", :log => "Deleted the #{@group.name}(#{@group.id}) group.")
         flash[:notice] = "<div class=\"flash_success\">Group deleted!</div>"
         @group.destroy
       else
         flash[:notice] = "<div class=\"flash_failure\">Sorry, This group cannot be deleted.</div>"         
       end 
     end
     redirect_to :action => 'index'
   end


  def edit
    @group = Group.find(params[:id])
    @plugins = Plugin.find(:all, :order => "order_number ASC")   
  end

  def new
  end


end
