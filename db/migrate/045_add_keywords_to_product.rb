# encoding: utf-8
class AddKeywordsToProduct < ActiveRecord::Migration
  def self.up
    change_table :products do |t|
      t.string :keywords
    end
  end

  def self.down
    change_table :products do |t|
      t.remove :keywords
    end
  end
end
