# encoding: utf-8
class AddInfiltersToTags < ActiveRecord::Migration
  class Tag < ActiveRecord::Base
  end
  def self.up
    add_column :tags, :infilters, :boolean, :default => false

    Tag.find_each do |tag|
      tag.infilters = true
      tag.save!
    end
  end

  def self.down
    remove_column :tags, :infilters
  end
end
