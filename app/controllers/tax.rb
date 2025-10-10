# encoding: utf-8
class Order < ActiveRecord::Base

	def parse_price(key)
        i = 0
        str = ""
        #@sum = Order_product.where('id' + @last_id.to_s + '')
        @sum = Order_product.where('id = ' + key.to_s + '').to_json
        parse_title = @sum.scan(/title+\W+"([А-Яа-яЁё\s\d().]+)/).to_a
        parse_price =  @sum.scan(/[^_]price+\W+([\d]+)/).to_a 
        parse_quantity = @sum.scan(/quantity+\W+([\d]+)/).to_a
        deliveries_price = Order.last.del_price
        parse_array = parse_title.zip(parse_price, parse_quantity)
        length_array = parse_array.length
		lmi_del_name = "&LMI_SHOPPINGCART.ITEMS[#{length_array}].NAME=Доставка"
		lmi_del_quantity = "&LMI_SHOPPINGCART.ITEMS[#{length_array}].QTY=1"
		lmi_del_price = "&LMI_SHOPPINGCART.ITEMS[#{length_array}].PRICE=#{deliveries_price}"
		lmi_del_tax = "&LMI_SHOPPINGCART.ITEMS[#{length_array}].TAX=vat0"
        loop do
            pt = parse_title[i].to_s.gsub('[', '').gsub('"','').gsub('"', '').gsub(']','')
            pp = parse_price[i].join.to_i
            pq = parse_quantity[i].join.to_i
            lmi_name = "&LMI_SHOPPINGCART.ITEMS[#{i}].NAME=#{pt}"
            str.concat(lmi_name)
            lmi_quantity = "&LMI_SHOPPINGCART.ITEMS[#{i}].QTY=#{pq}"
            str.concat(lmi_quantity)
            lmi_price = "&LMI_SHOPPINGCART.ITEMS[#{i}].PRICE=#{pp}"
            str.concat(lmi_price)
            lmi_tax = "&LMI_SHOPPINGCART.ITEMS[#{i}].TAX=vat0"
            str.concat(lmi_tax).to_s
            i+=1
            break if i==length_array
        end
        return str.concat(lmi_del_name).concat(lmi_del_quantity).concat(lmi_del_price).concat(lmi_del_tax)

    end	

end

