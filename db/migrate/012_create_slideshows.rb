# encoding: utf-8
class CreateSlideshows < ActiveRecord::Migration
  def self.up
	create_table :slideshows do |t|
	    t.string :title
	    t.boolean :active
	  	t.timestamps
	end
  end

  def self.down
    drop_table :slides
  end
end
