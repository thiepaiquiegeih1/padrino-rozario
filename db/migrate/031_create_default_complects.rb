# encoding: utf-8
class CreateDefaultComplects < ActiveRecord::Migration
  def self.up
    ["Стандартный","Уменьшенный","Люкс"].each do |name|
      Complect.create(title: name)
    end
  end

  def self.down
    Complect.destroy_all
  end
end
