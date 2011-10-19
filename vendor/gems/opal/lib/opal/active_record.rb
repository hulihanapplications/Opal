module Opal
  module ActiveRecord
    module Base
      module InstanceMethods
        # assign order number, used in sorting
        def assign_order_number 
          self.order_number = self.class.next_order_number
        end 
        
        def sanitize_content(attribute)
       	  self.class.send(:include, ::ActionView::Helpers::SanitizeHelper)
          self.send((attribute.to_s + "=").to_sym, sanitize(self.send(attribute.to_sym)))
        end        
        
        def create_log(options = {})# create a log
          options[:log_type] = "unknown" if options[:log_type].blank?
          l = Log.new(options)
          l.target_id = self.id
          l.target_type = self.class.name
          l.user_id = self.user_id if respond_to?(:user_id)
          l.item_id = self.item_id if respond_to?(:item_id)       
          l.save
          return l
        end         
        
        def is_viewable_for_user?(user) # Can the current user see this record?
          if user.is_admin? || self.user_id == user.id # User is an admin, or the user that created the item. Item owners can always see their item, but no one else can, if not allowed.
            return true
          else # not an admin or user that created item.
              if self.is_public == "1" && self.is_approved == "1"
                return true
              elsif (self.is_public == "0" && self.is_approved == "1") # It's not public, but is approved 
                return false
              else # not public or viewable
                return false
              end
          end
        end
        
        def is_editable_for_user?(user) # can the user edit this record?
           if ((self.is_user_owner?(user) && respond_to?(:locked) ? !locked : true) || user.is_admin?)  # Yes, the item belongs to the user
             return true
           else # The item does not belong to the user.
             return false
           end
        end
        
        def is_deletable_for_user?(user) # can the user delete this record?
          if user.is_admin? # User is an admin
            return true
          else # not an admin    
            return self.is_user_owner?(user) && respond_to?(:locked) ? !locked : true # check if user that owns this item and users are allowed to delete items
          end
        end            
        
        def is_user_owner?(user)
          self.user_id == user.id # is this user the owner?
        end
        
        def is_new? # has the item been recently added?
          max_hours = 72 # the item must be added within the last x hours to be considered new 
          return ((Time.now - self.created_at) / 3600) < max_hours # convert secs to hours 
        end      
        
        # check if a performer object(User, etc.) can do something to/regarding this object/instance
        #   @page.can?(User.anonymous, :destroy) => false 
        # Override this in model for custom functionality        
        def can?(performer, action, options = {})
          case performer          
          when User
            case action.to_sym        
            when :edit, :update, :destroy, :delete
              (self.is_user_owner?(performer) && !performer.anonymous?) || performer.is_admin?
            end
          end 
        end          
      end
      
      module ClassMethods
        # check if a performer object(User, etc.) can do something to/regarding this class
        #   Page.can?(User.anonymous, :create) => false 
        # Override this in model for custom functionality
        # Options:
        #   belongs_to: will the record belong to another record/object? If so, then the owner of the parent object might have special rights
        def can?(performer, action, options = {})
          case performer       
          when User
            case action.to_sym
            when :new, :create, :view, :read
              performer.is_admin?
            end
          end 
        end        
        
        # Get the next order number in line for sorting
        def next_order_number
          last_record = self.find(:last, :order => "order_number ASC")
          last_record ? order_number = last_record.order_number + 1 : order_number = 0
          return order_number         
        end        
        
        # get the controller name of a model
        #   User.controller_name => "users"
        def controller_name 
          to_s.tableize 
        end 
        
        def test
          "Testing..."
        end      
      end
    end 
  end
end