# encoding: utf-8
class CreateSlides < ActiveRecord::Migration
  def self.up
	create_table :slides do |t|
		t.integer :slideshow_id 
	    t.string :image
	    t.string :uri
	    t.text :text
	  	t.timestamps
	end
  end

  def self.down
    drop_table :slides
  end
end
