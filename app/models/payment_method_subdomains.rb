# encoding: utf-8
class PaymentMethodSubdomains < ActiveRecord::Base
  self.table_name = 'payment_methods_subdomains'
  validates :name, presence: true
  validates :order, presence: true
end
