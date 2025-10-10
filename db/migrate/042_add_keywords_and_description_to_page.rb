# encoding: utf-8
class AddKeywordsAndDescriptionToPage < ActiveRecord::Migration
  def self.up
    change_table :pages do |t|
      t.string :keywords
      t.string :description
    end
  end

  def self.down
    change_table :pages do |t|
      t.remove :keywords
      t.remove :description
    end
  end
end
