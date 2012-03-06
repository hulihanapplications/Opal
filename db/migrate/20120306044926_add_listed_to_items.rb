class AddListedToItems < ActiveRecord::Migration
  def change
    add_column :items, :listed, :boolean, :default => true
  end
end
