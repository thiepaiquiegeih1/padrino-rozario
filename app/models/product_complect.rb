# encoding: utf-8

class ProductComplect < ActiveRecord::Base
  belongs_to :product
  belongs_to :complect
  mount_uploader :image, UploaderProduct

  def chk_price(dp_id)
    if    dp_id==1290; if price;      return true; end
    elsif dp_id==1990; if price_1990; return true; end
    elsif dp_id==2890; if price_2890; return true; end
    elsif dp_id==3790; if price_3790; return true; end
    end
  end

  def self.check(value)
    if value == 'true'
      $value = 'true'
      return 'true'
    else
      $value = 'false'
      return 'false'
    end
  end

  def get_price(dp_id=1290)
    if dp_id==1290
      if over_1290 and $value == 'true'
        return over_1290
      elsif price and $value == 'true'
        return price + (((price/100*15).to_f*0.1).round()*10).to_i
      else
        return price
      end
    elsif dp_id==1990; if over_1990 and $value == 'true'; return over_1990; elsif price_1990 and $value == 'true'; return price_1990 + (((price_1990/100*15).to_f*0.1).round()*10).to_i; else; return price_1990; end
    elsif dp_id==2890; if over_2890 and $value == 'true'; return over_2890; elsif price_2890 and $value == 'true'; return price_2890 + (((price_2890/100*15).to_f*0.1).round()*10).to_i; else; base = price_2890; return base; end
    elsif dp_id==3790; if over_3790 and $value == 'true'; return over_3790; elsif price_3790 and $value == 'true'; return price_3790 + (((price_3790/100*15).to_f*0.1).round()*10).to_i; else; base = price_3790; return base; end; end
  end

  def type
    Complect.find_by_id(complect_id).title
  end

  def header
    Complect.find_by_id(complect_id).header
  end

end