# encoding: utf-8
class AddCrosssellcatToSubdomain < ActiveRecord::Migration
  def self.up
      change_table :subdomains do |t|
          t.integer :crosssel_categorygroup_id

      end
  end

  def self.down
    change_table :subdomains do |t|
       t.remove :crosssel_categorygroup_id
    end
  end
end
