class PluginFeatureValue < ActiveRecord::Base
  # the plugin_feature_value is an interesting type of plugin, it actually 
  #       is a child of another psuedo plugin, the plugin_feature. I want plugin
  #       functionality to be able to support inheritance, not just a plain pointer to an
  #       plugin_whatever value set. 
  belongs_to :plugin_feature
  belongs_to :user
  
  validates_presence_of :value
  #validates_uniqueness_of  :record_id, :scope => :plugin_feature_id
  attr_accessible :value

  acts_as_opal_plugin :notifications => false
  
  def to_s
  	value
  end
  
  def self.plugin
    Plugin.where(:name => "Feature").first
  end
  
=begin 
 def validate # run validations for value
   if self.feature.feature_type == "number" || self.feature.feature_type == "slider" 
     if entered_value !~ /^\s*[+-]?((\d+_?)*\d+(\.(\d+_?)*\d+)?|\.(\d+_?)*\d+)(\s*|([eE][+-]?(\d+_?)*\d+)\s*)$/ # is this a float?
       
       errors[feature.name] = "is not a number!"
     else # this is a number
       # Check if within range
       if feature.min # check if below min
          errors[feature.name] = "must be greater than #{feature.min}" if entered_value.to_f < feature.min  # add requirement error            
       end 
       
       if feature.max # check if above max
           errors[feature.name] = "must be less than #{feature.max}" if entered_value.to_f > feature.max  # add requirement error            
       end         
     end       
   end
 end
=end 
end
