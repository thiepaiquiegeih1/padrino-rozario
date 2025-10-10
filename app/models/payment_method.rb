# encoding: utf-8
class PaymentMethod < ActiveRecord::Base
  self.table_name = 'payment_methods'
  validates :name, presence: true
  validates :order, presence: true
end
