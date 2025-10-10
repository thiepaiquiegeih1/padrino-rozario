# encoding: utf-8
class CreateCategorygroups < ActiveRecord::Migration
  def self.up
    create_table :categorygroups do |t|
      t.string :title
    end
  end

  def self.down
    drop_table :categorygroups
  end
end
