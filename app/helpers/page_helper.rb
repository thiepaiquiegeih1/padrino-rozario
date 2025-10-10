# encoding: utf-8
Rozario::App.helpers do

  def getpage(uri)
    Page.find_by_uri(uri)
  end

    def abs_url_for(*args)
      url(*args)
    end

    def host_url(path)
      path
    end

    def show_address
      if @seo[:h1]
        # return "<h1>#{@seo[:h1].html_safe}</h1><span class='span2'>тел.:</span><span class='span2'> <span>8 (800) 250-64-70</span><span class='span2'> (бесплатно по России)</span>"
        return "<span class='span2'>тел.:</span><span class='span2'> <span>8 (800) 250-64-70</span><span class='span2'> (бесплатно по России)</span>"
      else
        # return "<span>Цветы с доставкой. <br>Когда расстояние - не преграда!</span><br><span class='span2'>тел.:</span><span class='span2'> <span>8 (800) 250-64-70</span><span class='span2'> (бесплатно по России)</span>"
      end
    end

    def show_address_mobile
      if @address.present?
        "Заказ и доставка цветов <br>в #{@address}тел.:<span>8 (800) 250-64-70</span> <span class='span2'>(бесплатно по России)<span><br /><br />"
      else
        "Заказ и доставка цветов <br>тел.:<span>8 (800) 250-64-70</span> <span class='span2'>(бесплатно по России)<span><br /><br />"
      end
    end

    def show_phone
      if @address.present?
        "8 (800) 250-64-70"
      else
        "8 (8152) 70-64-70"
      end
    end
end
