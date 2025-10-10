# encoding: utf-8
class AddTitleToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :title, :string
  end
end
