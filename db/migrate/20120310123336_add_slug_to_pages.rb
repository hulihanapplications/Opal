class AddSlugToPages < ActiveRecord::Migration
  def up
    add_column :pages, :slug, :string
    add_index :pages, :slug, :unique => true
  end

  def down
    remove_column :pages, :slug
    remove_index :pages, :slug if index_exists?(:pages, :slug)
    # Reset columns so FriendlyID won't break other migrations
    Page.reset_column_information
  end 
end
