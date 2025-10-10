# encoding: utf-8
# CREATE TABLE `payment_methods` (
#   `id` int NOT NULL AUTO_INCREMENT PRIMARY KEY,
#   `name` varchar(128) NOT NULL,
#   `order` int NOT NULL UNIQUE
# );

# CREATE TABLE `payment_methods_subdomains` (
#   `id` int NOT NULL AUTO_INCREMENT PRIMARY KEY,
#   `name` varchar(128) NOT NULL,
#   `order` int NOT NULL UNIQUE
# );

Rozario::Admin.controllers :payment_methods do

  get :index do
    # @subdomains = Subdomain.order('city ASC').all.map{|s| {id: s.id, name: s.city+" ("+s.url+")"}}
    @payment_methods = PaymentMethod.all
    @payment_methods_subdomains = PaymentMethodSubdomains.all
    render 'payment_methods/index'
  end

  post :save do
    content_type :json
    payload = JSON.parse(request.body.read)
    table = payload['table']
    begin
      cndtns = []
      ActiveRecord::Base.transaction do
        order = 0
        payload['methods'].each { |payment_method_name|
          order = order + 1
          case table
            when 'payment_methods'
              x = PaymentMethod.where(order: order).first
              if x.nil?; x = PaymentMethod.new({order: order}); end
            when 'payment_methods_subdomains'
              x = PaymentMethodSubdomains.where(order: order).first
              if x.nil?; x = PaymentMethodSubdomains.new({order: order}); end
          end
          x.name = payment_method_name
          if x.save; cndtns.append(true); else; cndtns.append(false); end
        }
        while true
          order = order + 1
          case table
            when 'payment_methods'
              x = PaymentMethod.where(order: order).first
              if x.nil?; break; end
            when 'payment_methods_subdomains'
              x = PaymentMethodSubdomains.where(order: order).first
              if x.nil?; break; end
          end
          x.delete
        end
      end
    rescue
      status 500; return { sccss: false, msg: "Internal Server Error | :(" }.to_json
    else
      if cndtns.map { |i| i }.all?; status 200; return { sccss: true }.to_json
      else; status 500; return { sccss: false, msg: "Internal Server Error | :(" }.to_json; end
    end
  end
end

