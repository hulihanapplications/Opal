class CreatePluginFeatureValueOptions < ActiveRecord::Migration
  # FeatureValueOptions let users select from pre-defined values for a particular Feature. 
  # Example: If there was a feature called "Size", you could create a FeatureValueOption 
  #          called "Medium", that a user could select instead of typing "Medium" 
  def self.up
    create_table :plugin_feature_value_options do |t|
      t.column :plugin_feature_id, :integer, :nil => false
      t.column :user_id, :integer, :nil => false # who created this      
      t.column :value, :string, :nil => false # the value They can select
      t.column :description, :string # description of the value, optional
      t.column :created_at, :datetime#this will get populated automatically
      t.column :updated_at, :datetime#this will get populated automatically
      t.timestamps
    end
  end

  def self.down
    drop_table :plugin_feature_value_options
  end
end
