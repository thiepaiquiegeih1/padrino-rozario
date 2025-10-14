# encoding: utf-8
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
  scope :published, -> { where("published = b'1' OR published = 1 OR published = '\\x01'") }
  scope :unpublished, -> { where("published = b'0' OR published = 0 OR published = '\\x00' OR published IS NULL") }
  
  # Helper метод для проверки статуса публикации с учетом особенностей BIT поля
  def published?
    # В MySQL BIT(1) может возвращаться как строка "\x01" для 1 и "\x00" для 0
    # Или как число 1/0, или как булево значение
    case published
    when "\x01", 1, true
      true
    when "\x00", 0, false, nil
      false
    else
      # Для других случаев пытаемся конвертировать в число
      published.to_i == 1
    end
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
