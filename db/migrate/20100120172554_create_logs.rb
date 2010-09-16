class CreateLogs < ActiveRecord::Migration
  def self.up
    create_table :logs do |t|
      t.column :user_id, :integer, :nil => false # if performed by a user, optional
      t.column :item_id, :integer, :nil => false # if related to an item, optional
      t.column :log, :string  # the actual log.
      t.column :log_type, :string # the type of log, shows a special icon for edit, create, delete, etc.
      t.timestamps
    end
  end

  def self.down
    drop_table :logs
  end
end