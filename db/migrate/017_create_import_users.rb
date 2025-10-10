# encoding: utf-8
class CreateImportUsers < ActiveRecord::Migration
  def self.up
	create_table :import_users do |t|
	    t.string :name
	    t.string :email
	    t.string :subscribe_code
	    t.boolean :subscribe, :default => true
	  	t.timestamps
	end
  end

  def self.down
    drop_table :import_users
  end
end
