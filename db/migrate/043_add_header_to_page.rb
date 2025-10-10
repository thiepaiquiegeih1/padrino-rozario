# encoding: utf-8
class AddHeaderToPage < ActiveRecord::Migration
  def self.up
    change_table :pages do |t|
      t.string :header
    end
    Page.update_all('header=title')
  end

  def self.down
    change_table :pages do |t|
      t.remove :header
    end
  end
end
