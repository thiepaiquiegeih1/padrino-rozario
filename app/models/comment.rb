# encoding: utf-8
require_relative '../helpers/common.rb'

class Comment < ActiveRecord::Base
  
  # Связь с заказом через eight_digit_id
  belongs_to :order, foreign_key: :order_eight_digit_id, primary_key: :eight_digit_id
  
  # Валидация номера заказа (если указан)
  validates_numericality_of :order_eight_digit_id, 
    :only_integer => true, 
    :greater_than => 9_999_999, 
    :less_than => 100_000_000,
    :allow_blank => true
  
  # Проверка существования заказа
  validate :order_exists_if_provided
  
  # Scopes для работы с BIT полем published
  scope :published, -> { where(published: 1) }
  scope :unpublished, -> { where(published: 0) }
  
  # Helper метод для проверки статуса публикации
  def published?
    # Используем проверенный helper из common.rb
    bit_field_to_bool(published)
  end
  
  private
  
  def order_exists_if_provided
    return if order_eight_digit_id.blank?
    
    unless Order.exists?(:eight_digit_id => order_eight_digit_id)
      errors.add(:order_eight_digit_id, "Заказ с номером #{order_eight_digit_id} не найден")
    end
  end

end

class Comment_premod < ActiveRecord::Base

end
