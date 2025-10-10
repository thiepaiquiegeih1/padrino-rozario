# encoding: utf-8
class CreateNews < ActiveRecord::Migration

  def self.up
    create_table :news do |t|
      t.string :title
      t.text :announce
      t.text :body
      t.string :image
      t.timestamps
    end
  end

  def self.down
    drop_table :news
  end

end