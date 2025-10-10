# encoding: utf-8
class ChangePagesBodyType < ActiveRecord::Migration
  def self.up
    change_column :pages, :body, :longtext
  end

  def self.down
    change_column :pages, :body, :text
  end
end
