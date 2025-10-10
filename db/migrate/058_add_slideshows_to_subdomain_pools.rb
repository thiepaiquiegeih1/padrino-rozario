# encoding: utf-8
class AddSlideshowsToSubdomainPools < ActiveRecord::Migration
    def self.up
        change_table :subdomain_pools do |t|
            t.integer :slideshow_main_id
            t.integer :slideshow_cart_id
            t.boolean :enable_slideshows
        end
    end

    def self.down
      change_table :subdomain_pools do |t|
         t.remove :slideshow_main_id
         t.remove :slideshow_cart_id
         t.remove :enable_slideshows
      end
    end
end
