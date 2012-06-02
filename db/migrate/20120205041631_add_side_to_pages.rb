class AddSideToPages < ActiveRecord::Migration
  def change
    add_column :pages, :side, :text
  end
end
