# encoding: utf-8
class AddSubscribeUseraccounts < ActiveRecord::Migration
  def self.up
    add_column(:user_accounts, :subscribe, :boolean, :default => true)
    add_column(:user_accounts, :subscribe_code, :string)
  end

  def self.down
    remove_column(:user_accounts, :subscribe_code)
    remove_column(:user_accounts, :subscribe)
  end
end
