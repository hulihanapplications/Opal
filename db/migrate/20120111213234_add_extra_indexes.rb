class AddExtraIndexes < ActiveRecord::Migration
  def up
    add_index :users, :username
    add_index :users, :email
    add_index :users, :persistence_token
    add_index :users, :last_request_at   
    add_index :settings, :name
    add_index :groups, :name    
    add_index :plugins, :name               
    add_index :pages, :name
    add_index :pages, :title                              
  end

  def down
    remove_index :users, :username
    remove_index :users, :email
    remove_index :users, :persistence_token
    remove_index :users, :last_request_at   
    remove_index :settings, :name
    remove_index :groups, :name  
    remove_index :plugins, :name        
    remove_index :pages, :name
    remove_index :pages, :title                      
  end
end
