# encoding: utf-8
class UserAccount < ActiveRecord::Base
  has_many :remembers
  def gen_subscribe_code
    self.subscribe_code = self.subscribe_code.blank? ? SecureRandom.hex(5) : self.subscribe_code
  end

  def self.gen_all_subscribe_code
    UserAccount.all.each do |user|
      user.gen_subscribe_code
      user.save
    end
  end

  def user_json(ret, del)
    str = ''
    i = 1
    lmi_del_name = "&LMI_SHOPPINGCART.ITEMS[0].NAME=Доставка"
    lmi_del_quantity = "&LMI_SHOPPINGCART.ITEMS[0].QTY=1"
    lmi_del_price = "&LMI_SHOPPINGCART.ITEMS[0].PRICE=#{del}"
    lmi_del_tax = "&LMI_SHOPPINGCART.ITEMS[0].TAX=vat0"
    for item in ret
      @title = item.title.to_json
      @price = item.price.to_json
      @quantity = item.quantity.to_json
      title = "&LMI_SHOPPINGCART.ITEMS[#{i}].NAME=#{@title}"
      str.concat(title)
      quantity = "&LMI_SHOPPINGCART.ITEMS[#{i}].QTY=#{@quantity}"
      str.concat(quantity)
      price = "&LMI_SHOPPINGCART.ITEMS[#{i}].PRICE=#{@price}"
      str.concat(price)
      tax = "&LMI_SHOPPINGCART.ITEMS[#{i}].TAX=no_vat"
      str.concat(tax)
      i += 1
    end
    return str.concat(lmi_del_name).concat(lmi_del_quantity).concat(lmi_del_price).concat(lmi_del_tax)
  end
  
end
