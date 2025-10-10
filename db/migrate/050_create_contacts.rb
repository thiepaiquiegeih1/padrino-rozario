# encoding: utf-8
class CreateContacts < ActiveRecord::Migration
  def self.up
    create_table :contacts do |t|
      t.string :name
      t.string :header
      t.text :body
      t.text :about_us_short
      t.integer :subdomain_id
      t.boolean :enabled
      t.timestamps
    end

    add_index :contacts, :subdomain_id, :unique => true
  end

  def self.down
    drop_table :contacts
  end
end

