class AddGroupAccessToPages < ActiveRecord::Migration
  def change
    add_column :pages, :group_access_only, :boolean, :default => false
    add_column :pages, :group_ids, :string    
  end
end
