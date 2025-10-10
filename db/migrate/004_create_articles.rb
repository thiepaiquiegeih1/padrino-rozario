# encoding: utf-8
class CreateArticles < ActiveRecord::Migration
  def self.up
create_table :articles do |t|
  t.string :title
      t.text :announce
      t.text :body
  t.timestamps
end
  end

  def self.down
    drop_table :articles
  end
end
