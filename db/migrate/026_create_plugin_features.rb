class CreatePluginFeatures < ActiveRecord::Migration
  # A Bullet is just the template of the feature, users ONLY have control of the feature value, The Admin adds the actual feature template.
  # This is a special type of item object.
  def self.up
    create_table :plugin_features do |t|
      #t.column :item_id, :integer, :nil => false # Dave: we won't need this because the plugin_feature_value will have the 
      #t.column :user_id, :integer, :nil => false
      t.column :name, :string, :default => "" # The Title of the Description
      t.column :order_number, :integer, :default => 0
      t.column :created_at, :datetime#this will get populated automatically
      t.column :updated_at, :datetime#this will get populated automatically
    end
  end

  def self.down
    drop_table :plugin_features
  end
end
