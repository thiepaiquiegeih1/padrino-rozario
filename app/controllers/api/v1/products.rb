# encoding: utf-8

Rozario::App.controllers :products, map: 'api/v1/products' do
  get :discounted do
    content_type :json
    collector = []; current_time = Time.now
    ProductComplect.where("discounts IS NOT NULL AND discounts != '' AND discounts != '[]' AND discounts != '[]\n' AND discounts != '\n'").each do |product_сomplect|
      begin
        JSON.parse(product_сomplect.discounts).each do |discount|
          percent    = discount["percent"] || 0
          cap        = discount["cap"]     || 0
          shedule    = discount["shedule"] || '* * * * *'
          start_time = convert_to_utc_plus_3(discount["period"]["datetime_start"])
          end_time   = convert_to_utc_plus_3(discount["period"]["datetime_end"])
          if percent > 0 && matches_cron?(shedule) && start_time <= current_time && current_time <= end_time # Проверяем, входит ли текущее время в промежуток
            result = {
              percent: percent,
              cap: cap,
              shedule: shedule,
              period: {
                datetime_start: discount["period"]["datetime_start"],
                datetime_end: discount["period"]["datetime_end"]
              }
            }
            product_сomplect.discounts = result.to_json
            collector.append(product_сomplect)
          end
        end
      rescue # StandardError => e
        next
      end
    end
    return collector.to_json
  end
end
