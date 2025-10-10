# encoding: utf-8
class AddTypeToSubdomain < ActiveRecord::Migration
  def self.up
    change_table :subdomains do |t|
      t.integer :domain_type
    end
  end

  def self.down
    change_table :subdomains do |t|
      t.remove :domain_type
    end
  end
end
