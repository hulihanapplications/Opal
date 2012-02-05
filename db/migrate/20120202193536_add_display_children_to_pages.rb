class AddDisplayChildrenToPages < ActiveRecord::Migration
  def change
    add_column :pages, :display_children, :boolean, :default => true
  end
end
