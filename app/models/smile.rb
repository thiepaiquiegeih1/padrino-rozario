# encoding: utf-8
class Smile < ActiveRecord::Base
	include ActiveModel::Validations

  belongs_to :seo, dependent: :destroy
  accepts_nested_attributes_for :seo, allow_destroy: true
  validates_presence_of :title
  validates_uniqueness_of :slug
  
  # Валидация номера заказа (если указан)
  validates_numericality_of :order_eight_digit_id, 
    :only_integer => true, 
    :greater_than => 9_999_999, 
    :less_than => 100_000_000,
    :allow_blank => true
    
  # Проверка существования заказа
  validate :order_exists_if_provided
  
  # Связь с заказом через eight_digit_id
  belongs_to :order, foreign_key: :order_eight_digit_id, primary_key: :eight_digit_id

	mount_uploader :images, UploaderSmile

  # Метод для получения имени клиента через json_order
  def customer_name
    return "Покупатель" unless json_order.present?
    
    begin
      # Парсим json_order и берем первый элемент ("0")
      order_data = JSON.parse(json_order)
      first_item = order_data['0']
      return "Покупатель" unless first_item && first_item['id']
      
      # id в json_order - это ID заказа, а не товара
      order_id = first_item['id'].to_i
      return "Покупатель" unless order_id > 0
      
      # Поиск заказа по точному ID
      matching_order = Order.find_by_id(order_id) || Order.find_by_eight_digit_id(order_id)
      
      return "Покупатель" unless matching_order
      return "Покупатель" unless matching_order.useraccount_id && matching_order.useraccount_id > 0
      
      user_account = UserAccount.find_by_id(matching_order.useraccount_id)
      return "Покупатель" unless user_account
      
      if user_account.surname && user_account.surname.present? && user_account.surname.strip.length > 0
        user_account.surname.strip
      else
        "Покупатель"
      end
      
    rescue => e
      # В случае ошибки возвращаем значение по умолчанию
      "Покупатель"
    end
  end
end

  private
  
  def order_exists_if_provided
    return if order_eight_digit_id.blank?
    
    unless Order.exists?(:eight_digit_id => order_eight_digit_id)
      errors.add(:order_eight_digit_id, "Заказ с номером #{order_eight_digit_id} не найден")
    end
  end