# encoding: utf-8
class ImportUser < ActiveRecord::Base
  def gen_subscribe_code
    self.subscribe_code = self.subscribe_code.blank? ? SecureRandom.hex(5) : self.subscribe_code
  end

  def self.gen_all_subscribe_code
    ImportUser.all.each do |user|
      user.gen_subscribe_code
      user.save
    end
  end

  def self.create_or_find_by_email(arr)
    if arr.count != 3
      return false
    end

    email = arr[2]
    if ImportUser.where(:email => email).blank? && UserAccount.where(:email => email).blank?
      user = ImportUser.create(:name => arr[0], :email => email)
      user.gen_subscribe_code
      return user.save
    else
      return false
    end
  end
end
