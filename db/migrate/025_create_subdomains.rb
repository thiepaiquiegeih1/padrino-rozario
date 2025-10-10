# encoding: utf-8
class CreateSubdomains < ActiveRecord::Migration
  
  def self.up
    create_table :subdomains do |t|
      t.string :url
      t.string :city
      t.string :title
      t.string :keywords
      t.text :description
      t.text :about
      t.timestamps
    end
    add_index :subdomains, :url
  end

  def self.down
    remove_index :subdomains, :url
    drop_table :subdomains
  end
end
