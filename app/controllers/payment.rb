# encoding: utf-8

# С данным API на момент последнего обновления (05.02.2025) общается файл фронтенда ../../public/vue/js/app.3d997df6.js и непосредственно сервис платежей ЮKassa.

# JS код для отправки запроса из frontend'а (../../public/vue/js/app.3d997df6.js) в данный контроллёр:
#
# function errorHandler(emsg) {
#   console.error('ERROR:', emsg);
#   alert('Мы сожалеем, но произошла ошибка. Пожалуста, выберите иной способ оплаты или попробуйте позднее...');
#   window.location.href = '/cart#/order';
# }
# var xhr = new XMLHttpRequest();
# xhr.open('POST', '/payment', true);
# xhr.setRequestHeader('Content-Type', 'application/json');
# xhr.send(JSON.stringify({
#   'amount': {
#     'value': '${this.$store.state.order.summPrice}',
#     'currency': 'RUB'
#   }, 'metadata': { 'orderNumber': '${this.$store.state.order.order_id}' },
#   'description': 'Платёж за заказ № ${this.$store.state.order.order_id} в интернет-магазине Розарио.Цветы',
# }));
# xhr.onload = function() { if (xhr.status === 200) { var response = JSON.parse(xhr.responseText);
#   if (response.metadata.orderNumber.split('D')[0] == '${this.$store.state.order.order_id}') {
#     if (response.confirmation.type == 'redirect') {
#       // var otherWindow = window.open(); otherWindow.opener = null; otherWindow.location = response.confirmation.confirmation_url; // Safety open in new window (https://habr.com/ru/articles/282880/) // Popup blocking issues
#       // window.location.href = response.confirmation.confirmation_url; // Simulate a mouse click // https://www.w3schools.com/howto/howto_js_redirect_webpage.asp
#       window.location.replace(response.confirmation.confirmation_url); // Simulate an HTTP redirect // https://www.w3schools.com/howto/howto_js_redirect_webpage.asp
#     } else { errorHandler('No link for redirect');       }
#   } else   { errorHandler('Order numbers do not match'); }
# } else     { errorHandler(xhr.statusText);               }};
#
# PS: В файле ../../app/views/page/predopl1.erb и ../../app/views/user_accounts/payment.haml содержится идентичный код для проведения предоплаты или дополнительных плат по имеющемуся номеру заказа

# /* Исходный SQL запрос, которым создаётся таблица для работы данного контроллёра.
#
# CREATE TABLE payments (
#   ykid VARCHAR(36) NOT NULL, /* For MySQL >=8.0 use: ykid UUID NOT NULL, */
#   status VARCHAR(27) NOT NULL,
#   paid BIT(1) NOT NULL,
#   amount_value INT(12) NOT NULL,
#   amount_currency VARCHAR(3) NOT NULL,
#   order_number VARCHAR(36) NOT NULL,
#   order_number_dtstr VARCHAR(19) NOT NULL, /* The datetime string postfix (JSON) for `orderNumber` field, */
#   description VARCHAR(128) NOT NULL,
#   cart TEXT NOT NULL,
#   created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
#   expires_at TIMESTAMP NOT NULL,
#   refundable BIT(1) NOT NULL,
#   test BIT(1) NOT NULL
# );

# TD:
# - В коде используется метод JSON.parse для парсинга ответа от сервера. Однако, этот метод может быть уязвим для атак типа "JSON injection". Обновите конфигурацию и рассмотрите использование более безопасных методов, таких как JSON.safe_parse. В текущей конфигурации использование JSON.safe_parse выдаст ошибку: NoMethodError - undefined method `safe_parse' for JSON:Module
# - Net::HTTP - это старая библиотека, которая не поддерживает все современные возможности HTTP. Рассмотрите использование более современных библиотек, таких как HTTParty или Faraday.
# - Использование более безопасных методов для работы с базой данных: Вместо использования ActiveRecord::Base.connection.execute, можно использовать Payment.where(ykid: data[:ykid]).update_attributes(data) (в данной версии ActiveRecord не поддерживается).
# - Чтобы улучшить безопасность кода, необходимо избегать использования строкового форматирования для построения SQL-запросов, так как это может привести к уязвимости для SQL-инъекций. Вместо этого, следует использовать параметризованные запросы или методы ActiveRecord, которые автоматически экранируют пользовательский ввод.
# - Использование более надёжной генерации значения переменной idempotence_key с помощью специализированных библиотек для работы с UUID
# - Тестирование отправки чеков по 54-ФЗ (https://yookassa.ru/docs/support/merchant/payments/implement/test-store#federal-law-54-FZ)
# - Проверить доступность альтернативных путей для уведомлений
# - Чтобы работала функция `check_ip()` требуется версия Ruby >= 2.3. Обновите версию Ruby и удалите строку `return true # pass` из функции `check_ip()`

# API testing via BASh
  # payment information
    # doc: https://yookassa.ru/developers/api#get_payment
    # cmd: `curl "https://api.yookassa.ru/v3/payments/${payment_id}" -u "${YOOKASSA_TEST_SHOP_ID}:${YOOKASSA_TEST_SECRET_KEY}"`

require 'ipaddr' # Required Ruby Version >= 2.3

module PaymentSettings # Базовые константы. Некоторые подробности можно найти в документации: https://yoomoney.ru/i/forms/yc-program-interface-api-sberbank.pdf
  SHOP_ID             = ENV['YOOKASSA_SHOP_ID'].to_s # Required. Идентификатор магазина, который вы получили в личном кабинете ЮKassa (поле shopId).
  SECRET_KEY          = ENV['YOOKASSA_SECRET_KEY'].to_s # Required. Секретный ключ магазина, который вы получили в личном кабинете ЮKassa. Подробнее: https://yookassa.ru/docs/support/merchant/payments/implement/keys
  TEST_SHOP_ID        = ENV['YOOKASSA_TEST_SHOP_ID'].to_s # Тестовый магазин
  TEST_SECRET_KEY     = ENV['YOOKASSA_TEST_SECRET_KEY'].to_s # Секретный ключ тествового магазина
  REGISTER_URL        = 'https://api.yookassa.ru/v3/payments' # Required. URL for payment registrations
  RETURN_URL          = 'https://rozarioflowers.ru/payment/confirmation' # Required. Адрес, на который ЮKassa перенаправит пользователя по завершению оплаты. Адрес должен быть указан полностью, включая используемый протокол (например, https://test.ru вместо test.ru). Иначе ЮKassa перенаправит пользователя по адресу такого вида: http://<адрес_платежного_шлюза>/<адрес_продавца>. Относительный адрес не поддерживается. Т.е. адрес не должен начинаться на «.» и «/». Иначе вернется ошибка. Примеры корректных URL: https://www.test.com, https://test.com, www.test.com. Примеры некорректных URL: ../test.html, /test.html.
  EMAIL_FROM_4_ALERTS = ENV['ADMIN_EMAIL'].to_s # 'no-reply@rozariofl.ru' # Required. Email отправителя для уведомлений об ошибках.
  EMAIL_TO_4_ALERTS   = ENV['ADMIN_EMAIL'].to_s # Required. Email получателя для уведомлений об ошибках.
  DEBUG               = false # Required. Режим отладки. На данный момент в этом режиме ОТКЛЮЧАЮТСЯ уведомления об ошибках по электронной почте, указанной в параметре EMAIL4ALERTS, но сообщения о них начинают выводиться в консоль.
  BASE_CURRENCY       = 'RUB' # Required.
  BASE_VAT_CODE       = '1' # Required.
  TIME_ZONE           = 'Moscow' # Required. The time zone for a datetime string postfix (JSON) of `orderNumber` field. # UTC_OFFSET = 3 # Required. The UTC offset (hours) for a datetime string postfix (JSON) of `orderNumber` field.
  FISKAL_MODE         = '54-FZ' # or 'self-employed' # https://www.consultant.ru/document/cons_doc_LAW_42359/
end

def check_ip(ip) # Required Ruby Version >= 2.3
  return true # pass
  return false if ip.nil?
  allowed_ips = [
    # SRC: https://yookassa.ru/developers/using-api/webhooks#ip
    IPAddr.new('185.71.76.0/27'),
    IPAddr.new('185.71.77.0/27'),
    IPAddr.new('77.75.153.0/25'),
    IPAddr.new('77.75.156.11/32'),
    IPAddr.new('77.75.156.35/32'),
    IPAddr.new('77.75.154.128/25'),
    IPAddr.new('2a02:5180::/32'),
    # SRC: `ip addr show`
    IPAddr.new('127.0.0.1/8'),               # scope host lo
    IPAddr.new('::1/128'),                   # scope host noprefixroute
    IPAddr.new('91.226.82.202/32'),          # scope global eth0
    IPAddr.new('2a01:5560:1001:211f::1/64'), # scope global
    IPAddr.new('fe80::5652:ff:fe1a:794f/64') # scope link
  ]
  allowed_ips.any? { |allowed_ip| allowed_ip.include?(ip) }
  # PS. Обратите внимание, что данная фильтрация также работает и в Nginx
end

def alert(subj, code, msg='') # Error handler
  if PaymentSettings::DEBUG then
    puts 'ATTENTION! | ATTENTION! | ATTENTION!'
    puts 'app/controllers/payment.rb:'
    puts "ERROR #{code}: #{subj}"
    if msg != ''; puts msg; end
  else
    email do
      from PaymentSettings::EMAIL_FROM_4_ALERTS; to PaymentSettings::EMAIL_TO_4_ALERTS
      subject "Payment controller problem on  (#{subj})"
      body "grep -r #{code}\n\n#{msg}"
    end
  end
end

def symbolize_keys_recursive(hash)
  hash.each_with_object({}) do |(key, value), new_hash|
    new_hash[key.to_sym] = value.is_a?(Hash)? symbolize_keys_recursive(value) : value
  end
end

def recursive_http_request(http, request, attempts_number)
  response = http.request(request)
  if response.is_a?(Net::HTTPSuccess) || attempts_number == 1; return response 
  else
    sleep(1)
    return recursive_http_request(http, request, attempts_number - 1)
  end
end

Rozario::App.controllers :payment do

  include PaymentSettings

  # before do
  #   [...]
  # end

  get :test, :with => [:ykid] do # Получить информацию по тестовому платежу по его ID
    if Payment.exists?(ykid: params[:ykid])
      content_type :json
      payment = Payment.where(ykid: params[:ykid]).first # payment = Payment.find_by_sql("SELECT * FROM payments WHERE ykid = '#{params[:ykid]}'").first
      if payment.read_attribute(:test) == "\x01"; return payment.to_json
      else; halt 404; end
    else; halt 404; end
  end

  post %r{^/payment$|^/payment/test$} do # https://yookassa.ru/developers/api#create_payment

    case request.path # Вся разница между обращением к данному контроллеру по адресу `/payment` и тестовом вызове через `/payment/test` в подмене значений переменных `shop_id` и `secret_key`
    when '/payment'
      shop_id    = PaymentSettings::SHOP_ID
      secret_key = PaymentSettings::SECRET_KEY
    when '/payment/test'
      shop_id    = PaymentSettings::TEST_SHOP_ID
      secret_key = PaymentSettings::TEST_SECRET_KEY
    else
      halt 404 # Preventively.
    end

    payload = symbolize_keys_recursive(JSON.parse(request.body.read))
    idempotence_key = "#{SecureRandom.random_bytes(16).unpack("H*").first.gsub(/(.{8})(.{4})(.{4})(.{4})(.{12})/, '\1-\2-\3-\4-\5')}"
    datetime_postfix = Time.now.in_time_zone(PaymentSettings::TIME_ZONE).to_json[1, 25] # datetime_postfix = (Time.now.getutc + PaymentSettings::UTC_OFFSET * 3600).to_json[1, -1]
    data = {
      amount: { # Amount of payment
        value: payload[:amount][:value],
        currency: PaymentSettings::BASE_CURRENCY # payload[:amount][:currency]
      },
      # payment_method_data: { type: "bank_card" }, # Optional. Method of payment. Possibilities: https://yookassa.ru/developers/payment-acceptance/integration-scenarios/manual-integration/basics#integration-options
      capture: true, # Optional. Automatic acceptance of incoming payment. Default: false # https://yookassa.ru/developers/api?lang=ru#create_payment_capture
      confirmation: { # optional
        type: "redirect", # required
        # locale: 'ru_RU' ? 'en_US' # optional
        return_url: "#{PaymentSettings::RETURN_URL}?orderNumber=#{payload[:metadata][:orderNumber]}" # required
      },
      receipt: { # Data for creating a receipt... See more at https://yookassa.ru/developers/api#create_payment_receipt
        customer: {}, # User details. You should specify at least the basic contact information: email address (customer.email) or phone number (customer.phone). # https://yookassa.ru/developers/api#create_payment_receipt_customer
        items: [] # Required. List of products in an order. Receipts sent in accordance with 54-FZ can contain up to 100 items. Receipts for the self-employed can contain up to six items. # https://yookassa.ru/developers/api#create_payment_receipt_items
      },
      metadata: {
        orderNumber: "#{payload[:metadata][:orderNumber]}D#{datetime_postfix}" # Внутренний ID заказа передаваемый и обязательный для идентификации и группирования платежей в 1С. PS. Постфикс даты и времени необходим, т.к. для одного и того же заказа может быть назначено несколько платежей, однако ЮKassa не позволяет повторно использовать поле orderNumber, в то же время это поле является единственно необходимым для группирования платежей в 1С.
      },
      description: payload[:description].nil? ? '' : payload[:description] # optional
    }
    # Fill data for generating a check. Required? https://yookassa.ru/developers/api?lang=ru#create_payment_receipt
    #
    order = Order.where(eight_digit_id: data[:metadata][:orderNumber]).first
    if order.nil? # checkpoint
      code = '7dd7af68-ce27-48d3-876c-de277242f074'
      alert('Unknown order', code)
      status 500; return { sccss: false, msg: "Internal Server Error | #{code} | :(" }.to_json
    end
    # Get customer data from DB # https://yookassa.ru/developers/api?lang=ru#create_payment_receipt_customer
    data[:receipt][:customer][:full_name] = order.oname
    data[:receipt][:customer][:email]     = order.email
    data[:receipt][:customer][:phone]     = order.otel.gsub(/\D/, '')
    # data[:receipt][:customer][:inn] = ?
    #
    # Get cart from DB 
    cart = Order_product.find_by_sql("SELECT * FROM order_products WHERE id = #{order.id.to_s}")
    cart.each_with_index { |order_product, i| # Change the price to the corresponding price in the current subdomain (crutch) / Меняем цену на соответстующую цену в текущем поддомене (костыль).
      complect_id = Complect.where(title: order_product.typing).first.id
      product_complect = ProductComplect.where(product_id: order_product.product_id, complect_id: complect_id).first
      cart[i].price = product_complect.get_price(dp_id=@subdomain.discount_pool_id)
    }
    if cart.nil? # checkpoint
      code = '15a33f2c-60c8-40a9-970e-aeef3a760bac'
      alert('The cart was empty when making the payment', code)
      status 500; return { sccss: false, msg: "Internal Server Error | #{code} | :(" }.to_json
    end
    if payload[:metadata][:surcharge] # if additional payment is made...
      payments = Payment.where(order_number: payload[:metadata][:orderNumber])
      # products_from_other_payments = {}
      # payments.map { |payment| payment.cart.split('|') }.flatten.each { |x|
      #   id = x.split('!')[0]; quantity = x.split('!')[1].to_i
      #   if products_from_other_payments.has_key?(id); products_from_other_payments[id] = products_from_other_payments[id] + quantity
      #   else;                                         products_from_other_payments[id] = quantity; end
      # }
      # new_cart = []
      # for item in cart
      #   # Если продукт уже связан с оплатой, то проверяем в каком количестве, если продукт или какое-то его количество не связаны с оплатой, то добавляем новую корзину:
      #   if products_from_other_payments.has_key?(item.product_id.to_s) # Если продукт (в заказе) уже связан с оплатой
      #     if item.quantity.to_i > products_from_other_payments[item.product_id.to_s] # Если количество продукта (в заказе) превышает количество продутов, связанных с оплатой
      #       new_item = item
      #       new_item.quantity = item.quantity - products_from_other_payments[item.product_id.to_s]
      #       new_cart.append(new_item)
      #     end
      #   else; new_cart.append(item); end
      # end
      # cart = new_cart
      products_from_other_payments = payments.flat_map(&:cart).map { |x| [x.split('!')[0], x.split('!')[1].to_i] }.to_h
      cart = cart.map do |item| # Этот код выполняет обработку корзины товаров, корректируя количество товаров в текущей корзине на основании данных из других оплат.
        if products_from_other_payments.key?(item.product_id.to_s)
          if item.quantity.to_i > products_from_other_payments[item.product_id.to_s]
            item.quantity -= products_from_other_payments[item.product_id.to_s]; item
          end
        else; item; end
      end.compact
    end
    list_of_products_from_the_cart = cart.map { |item| "#{item.product_id}!#{item.quantity}" }.join('|')
    i = 1; total_price_of_the_cart = 0
    for item in cart
      total_price_of_the_cart += item.price
      data[:receipt][:items][i-1]                     = {}
      data[:receipt][:items][i-1][:description]       = item.title
      data[:receipt][:items][i-1][:amount]            = {}
      data[:receipt][:items][i-1][:amount][:value]    = item.price
      data[:receipt][:items][i-1][:amount][:currency] = PaymentSettings::BASE_CURRENCY # data[:amount][:currency]
      data[:receipt][:items][i-1][:vat_code]          = PaymentSettings::BASE_VAT_CODE
      data[:receipt][:items][i-1][:quantity]          = item.quantity
      # https://yookassa.ru/developers/api#create_payment_receipt_items
      if (PaymentSettings::FISKAL_MODE == '54-FZ' && i == 100) || (PaymentSettings::FISKAL_MODE == 'self-employed' && i == 6)
        code = 'cbfc2e92-8d73-4159-8c61-dc2975fb3012'
        alert('The limit on the number of product items for generating a receipt has been exceeded', code)
        status 500; return "Internal Server Error | #{code} | :("
      end;
      i = i + 1
    end

    if order.del_price.to_i > 0 # If there is delivery, add a record about it / Если есть доставка, добавить запись об этом.
      data[:receipt][:items] << {
        description: 'Доставка',
        amount: {
          value: order.del_price,
          currency: PaymentSettings::BASE_CURRENCY # data[:amount][:currency]
        },
        vat_code: PaymentSettings::BASE_VAT_CODE,
        quantity: 1
      }
    end

    # return "#{data.to_json}" # checkpoint

    if !total_price_of_the_cart==data[:amount][:value]
      code = 'd7e9f17c-6fab-4c1e-93fe-e100091bc555'
      alert('The total cost of the cart does not match', code)
      return "Internal Server Error | #{code} | :("
    end

    uri = URI.parse(PaymentSettings::REGISTER_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri)
    request.basic_auth(shop_id, secret_key)
    request.add_field('Idempotence-Key', idempotence_key)
    request.add_field('Content-Type', 'application/json')
    request.body = data.to_json # request.set_form_data(data) # for "Content-Type: application/x-www-form-urlencoded"
    response = recursive_http_request(http, request, 3)
    # return [response.code, JSON.parse(response.body), data].to_json # checkpoint
    if response.is_a?(Net::HTTPSuccess) then
      response_object = symbolize_keys_recursive(JSON.parse(response.body))
      # TD: проверить соответствие в строке `"recipient" : { "account_id" : "<SHOP_ID>", "gateway_id" : "<GATEWAY_ID>" },`
      payment = {
        ykid:               response_object[:id],
        status:             response_object[:status],
        paid:               response_object[:paid]? 1 : 0,
        amount_value:       response_object[:amount][:value],
        amount_currency:    response_object[:amount][:currency],
        order_number:       payload[:metadata][:orderNumber],
        order_number_dtstr: datetime_postfix[0, 19],
        description:        response_object[:description],
        cart:               list_of_products_from_the_cart,
        refundable:         response_object[:refundable]? 1 : 0, # Подлежит возврату.
        test:               response_object[:test]? 1 : 0,
        created_at:         response_object[:created_at],
        expires_at:         response_object[:expires_at],
      }
      if Payment.new(payment).save then
        status response.code; return response.body
      else
        code = 'c437bb00-e925-4fc3-b81a-754abe4e9139'
        alert('Failed to create a payment object', code)
        status 500; return "Internal Server Error | #{code} | :("
      end
    else
      code = '66b04d06-ddd5-45e9-a7f9-5b0f2b28a20d'
      msg = "Response code: #{response.code}\n\nResponse message: #{response.message}\n\nRequest data: #{JSON.pretty_generate(data)}"
      alert("Response: { code: #{response.code}, message: #{response.message}}", code, msg)
      status 500; return "Response: { code: #{response.code}, message: #{response.message}}" # return "Internal Server Error | #{code} | :("
    end
  end

  post :notice do # Link: /payment/notice # Данная ссылка используется платёжным сервисом для уведомлений о состоянии платежа и устанавливается в личном кабинете: https://yookassa.ru/my/merchant/integration/http-notifications. Метод POST является предпочтительным.
    # Пример команды для тестирования данного интерфейса. Убедитесь, что обновляемый объект действительно существует в БД
    # curl -X POST /payment/notice -H 'Content-Type: application/json' -d '{"type":"notification","event":"payment.succeeded","object":{"id":"2e330369-000f-5000-a000-12fbaa0e9dd0","status":"succeeded","amount":{"value":"2.00","currency":"RUB"},"income_amount":{"value":"1.93","currency":"RUB"},"description":"test","recipient":{"account_id":"426618","gateway_id":"2286525"},"payment_method":{"type":"yoo_money","id":"2e330369-000f-5000-a000-12fbaa0e9dd0","saved":false,"title":"YooMoney wallet 410011758831136","account_number":"410011758831136"},"captured_at":"2024-07-24T12:12:44.038Z","created_at":"2024-07-24T12:12:25.367Z","test":true,"refunded_amount":{"value":"0.00","currency":"RUB"},"paid":true,"refundable":true,"metadata":{"orderNumber":"666"}}}'
    content_type :json
    payload = symbolize_keys_recursive(JSON.parse(request.body.read))
    if check_ip(request.env['REMOTE_ADDR']) || check_ip(request.env['HTTP_X_FORWARDED_FOR']) # if original or immediate client IP is allowed, then ...
      if payload[:type] == 'notification'
        data = {
          ykid:            payload[:object][:id],
          status:          payload[:object][:status],
          paid:            payload[:object][:paid]? 1 : 0,
          amount_value:    payload[:object][:amount][:value].split('.')[0].to_i,
          amount_currency: payload[:object][:amount][:currency],
          description:     payload[:object][:description],
          refundable:      payload[:object][:refundable]? 1 : 0, # Подлежит возврату.
          test:            payload[:object][:test]? 1 : 0
          # created_at:      payload[:object][:created_at],
          # expires_at:      payload[:object][:expires_at],
        }
        case payload[:event] # Available events: https://yookassa.ru/developers/using-api/webhooks#available-events
        when 'payment.succeeded' # Payment made
          if Payment.exists?(ykid: data[:ykid])
            # return data.to_json # checkpoint
            payment = Payment.where(ykid: data[:ykid]).first # payment = Payment.find_by_sql("SELECT * FROM payments WHERE ykid = '#{data[:ykid]}'").first
            # return payment.first.to_json # checkpoint
            if true then # TD # payment.amount_value.to_i == data[:amount_value] && payment.ykid == data[:ykid] # checksum

              # ОБНОВЛЯЕМ ОБЪЕКТ ПЛАТЕЖА В БД
              # Внимание! Не должно быть запятой перед `WHERE`.
              sql = "UPDATE payments SET 
                status          = '#{data[:status]}',
                paid            = #{data[:paid]}
                /* amount_value    = #{data[:amount_value]}, */
                /* amount_currency = '#{data[:amount_currency]}', */
                /* description     = '#{data[:description]}', */
                /* refundable      = #{data[:refundable]}, */
                /* test            = #{data[:test]}, */
                /* expires_at      = #{data[:created_at]}, */
                /* expires_at      = #{data[:expires_at]}, */
                WHERE ykid = '#{payment.ykid}'"
              ActiveRecord::Base.connection.execute(sql) # ActiveRecord::Base.connection.execute("UPDATE payments SET status = :status, paid = :paid, amount_value = :amount_value, amount_currency = :amount_currency, description = :description, refundable = :refundable, test = :test WHERE ykid = :ykid", { status: data[:status], paid: data[:paid], amount_value: data[:amount_value], amount_currency: data[:amount_currency], description: data[:description], refundable: data[:refundable], test: data[:test], ykid: payment.ykid }) # Unsupported alternative method

              # ПРОВЕРЯЕМ СОХРАННОСТЬ ОБЪЕКТА ПЛАТЕЖА В БД
              payment = Payment.where(ykid: data[:ykid]).first
              condition = [ # value matching
                data[:status]          == payment.status,
                data[:paid]            == payment.paid.ord,
                # data[:amount_value]    == payment.amount_value,
                # data[:amount_currency] == payment.amount_currency,
                # data[:description]     == payment.description,
                # data[:refundable]      == payment.refundable.ord, # Подлежит возврату.
                # data[:test]            == payment.test.ord,
                # data[:created_at]    == payment.created_at,
                # data[:expires_at]    == payment.expires_at,
              ].map { |i| i }.all? # являются ли все значения в массиве true?

              # ВОЗВРАЩАЕМ ОТВЕТ ПО СОСТОЯНИЮ ОПЕРАЦИИ
              if condition; status 200; return { sccss: true }.to_json; else
                code = '435b8e4e-fae0-4098-bfb7-657d975d18e5'
                alert('Failed to update payment object in the DB upon notification', code)
                status 500; return { sccss: false, msg: "Internal Server Error | #{code} | :(" }.to_json
              end
            else
              code = '13610511-8579-4346-aea1-12661d90a2c9'
              alert('Hash sums do not match', code)
              status 500; return { sccss: false, msg: "Internal Server Error | #{code} | :(" }.to_json
            end
            # return data.to_json # checkpoint
          else
            code = 'f8eab24a-2739-407b-86b9-ef03082438d5'
            alert("A notification has been received for a payment #{data[:ykid]} that doesn't exist in the DB. Recieve data: #{payload.to_json}", code)
            status 500; return { sccss: false, msg: "Internal Server Error | #{code} | :(" }.to_json
          end
        when 'payment.waiting_for_capture' # Waiting for payment
          payment = Payment.where(ykid: data[:ykid]).first
          if payment.nil?; status 200; return { sccss: false, msg: "payment.canceled" }.to_json
          else
            ActiveRecord::Base.connection.execute("UPDATE payments SET status = '#{payload[:object][:status]}' WHERE ykid = '#{payload[:object][:id]}'")
            status 200; return { sccss: true, msg: "payment.waiting_for_capture" }.to_json
          end
        when 'payment.canceled' # Payment canceled, as it is not difficult to guess
          # TD: https://yookassa.ru/developers/payment-acceptance/after-the-payment/declined-payments
          payment = Payment.where(ykid: data[:ykid]).first
          if payment.nil?; status 200; return { sccss: false, msg: "payment.canceled" }.to_json
          else
            ActiveRecord::Base.connection.execute("UPDATE payments SET status = '#{payload[:object][:status]}' WHERE ykid = '#{payload[:object][:id]}'")
            status 200; return { sccss: true, msg: "payment.canceled" }.to_json
          end
        when 'refund.succeeded'; status 200; return { sccss: true, msg: "refund.succeeded" }.to_json
        else
          code = '15a33f2c-60c8-40a9-970e-aeef3a760bac'
          alert('Non-standard event in payment status notification', code)
          status 500; return { sccss: false, msg: "Internal Server Error | #{code} | :(" }.to_json
        end
      else
        code = 'a2768cae-c75f-4464-a37d-6c5b94004cc2'
        alert('Bad request', code)
        status 400; return { sccss: false, msg: "Bad request | #{code} | :(" }.to_json
      end
    else
      alert("check_ip(#{request.env['HTTP_X_FORWARDED_FOR']}) != true", '9d65cec6-3be6-432c-a78c-c4c6c953d155', request.env.map { |key, value| "#{key}: #{value}" }.join("\n"))
      status 403; return 'Who’re you? I didn’t call you...'
    end
  end

  get :confirmation do
    # status 200; return "Ok! #{params[:id]}"
    redirect_to "/"
  end

  get :info, :with => [:id] do # Получить информацию о платеже по идентификатору 
    content_type :json
    uri = URI.parse("https://api.yookassa.ru/v3/payments/#{params[:id]}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth(PaymentSettings::SHOP_ID, PaymentSettings::SECRET_KEY)
    response = http.request(request)
    if response.code.to_i == 200; return response.body
    else; return { error: response.code }.to_json; end
  end

  delete :payments_pending_expired_delete do # Найти и удалить записи о платежах со статусом 'pending' и истекшим сроком один день назад.
    # curl -X DELETE /payment/payments_pending_expired_delete
    content_type :json
    # PaymentTest.all.delete_all # NoMethodError
    payments_pending_expired = Payment.where(status: 'pending').where('expires_at < ?', 1.day.ago)
    if payments_pending_expired.empty?; status 200; return { sccss: true, msg: 'No pending payments (expired) found to delete' }.to_json; else
      count = payments_pending_expired.count
      if payments_pending_expired.delete_all; status 200; { sccss: true, msg: "#{count} pending payments (expired) were successfully removed from DB" }.to_json
      else;                                   status 500; { sccss: false, msg: 'Deleting pending payments (expired) failed' }.to_json; end
    end
  end
  # get :test do
  #   content_type 'text/plain'  # Устанавливаем заголовок как обычный текст
  #   request.env.map { |key, value| "#{key}: #{value}" }.join("\n")  # Преобразуем пары ключ-значение в строки и соединяем их
  # end
end
