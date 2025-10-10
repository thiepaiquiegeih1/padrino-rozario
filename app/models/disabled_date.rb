# encoding: utf-8
class DisabledDate < ActiveRecord::Base
  include ActiveModel::Validations

  has_and_belongs_to_many :subdomain

  validates :date, presence: true
end
