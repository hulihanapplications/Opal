class CreatePluginFeatureValues < ActiveRecord::Migration
  def self.up
    create_table :plugin_feature_values do |t|
      t.column :item_id, :integer, :nil => false
      t.column :plugin_feature_id, :integer, :nil => false
      t.column :user_id, :integer, :nil => false
      t.column :value, :string, :default => "" # The Title of the Description
      t.string :is_approved, :limit => 1, :default => "0" #has this review been approved by admins?
      t.column :created_at, :datetime#this will get populated automatically
      t.column :updated_at, :datetime#this will get populated automatically
      t.column :url, :string, :default => nil
    end
  end

  def self.down
    drop_table :plugin_feature_values
  end
end
