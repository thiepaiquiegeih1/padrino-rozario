# encoding: utf-8

Rozario::App.controllers :testing do
  
  before do
    # Базовая проверка поддомена для совместимости с основным приложением
    load_subdomain if respond_to?(:load_subdomain)
  end
  
  # GET /testing/email - форма для тестирования
  get :email do
    content_type :html
    
    html = <<-HTML
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Email Test - Rozario Flowers</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 40px auto; padding: 20px; background: #f9f9f9; }
        .container { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #333; text-align: center; margin-bottom: 30px; }
        .status { padding: 15px; margin: 15px 0; border-radius: 5px; }
        .success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .warning { background: #fff3cd; color: #856404; border: 1px solid #ffeaa7; }
        .info { background: #d1ecf1; color: #0c5460; border: 1px solid #bee5eb; }
        .form-group { margin: 20px 0; }
        label { display: block; margin-bottom: 5px; font-weight: bold; }
        input[type="text"], input[type="email"], textarea { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px; box-sizing: border-box; }
        textarea { height: 100px; resize: vertical; }
        button { background: #007cba; color: white; padding: 12px 30px; border: none; border-radius: 5px; cursor: pointer; font-size: 16px; }
        button:hover { background: #005a87; }
        .config-info { font-family: monospace; font-size: 12px; background: #f1f1f1; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .test-buttons { display: flex; gap: 10px; flex-wrap: wrap; margin: 20px 0; }
        .test-buttons button { background: #28a745; }
        .test-buttons button:hover { background: #1e7e34; }
        .test-buttons button.warning { background: #ffc107; color: #333; }
        .test-buttons button.warning:hover { background: #d39e00; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🧪 Email System Test</h1>
        
        <div class="info status">
            <strong>📧 Тестирование почтовой системы Rozario Flowers</strong><br>
            Проверяет отправку писем на настроенный адрес администратора.
        </div>
        
        <div class="config-info">
            <strong>Текущая конфигурация:</strong><br>
            ORDER_EMAIL: <strong>#{ENV['ORDER_EMAIL'] || 'НЕ УСТАНОВЛЕНА'}</strong><br>
            Delivery Method: <strong>#{settings.delivery_method rescue 'НЕИЗВЕСТНО'}</strong><br>
            Environment: <strong>#{PADRINO_ENV}</strong><br>
            Host: <strong>#{request.host rescue 'НЕИЗВЕСТНО'}</strong>
        </div>
        
        <div class="test-buttons">
            <a href="/testing/email/quick"><button type="button">⚡ Быстрый тест</button></a>
            <a href="/testing/email/detailed"><button type="button">📋 Подробный тест</button></a>
            <a href="/testing/email/feedback"><button type="button" class="warning">🔄 Тест как отзыв</button></a>
        </div>
        
        <hr style="margin: 30px 0;">
        
        <h2>📝 Кастомное письмо</h2>
        <form method="post" action="/testing/email/send">
            <div class="form-group">
                <label for="to">Получатель (оставьте пустым для ORDER_EMAIL):</label>
                <input type="email" id="to" name="to" placeholder="admin@example.com">
            </div>
            
            <div class="form-group">
                <label for="subject">Тема письма:</label>
                <input type="text" id="subject" name="subject" value="[TEST] Проверка email системы" required>
            </div>
            
            <div class="form-group">
                <label for="body">Текст письма:</label>
                <textarea id="body" name="body" required>Это тестовое письмо из системы Rozario Flowers.

Время отправки: #{Time.now.strftime('%d.%m.%Y %H:%M:%S')}
Сервер: #{request.host rescue 'неизвестно'}
Пользователь: тестирование

Если вы получили это письмо, значит email система работает корректно.</textarea>
            </div>
            
            <button type="submit">📧 Отправить письмо</button>
        </form>
        
        <div style="margin-top: 40px; font-size: 12px; color: #666; text-align: center;">
            <p>💡 <strong>Совет:</strong> Проверьте спам-папку, если письмо не приходит в основную папку.</p>
            <p>🔧 При проблемах проверьте логи: <code>tail -f /var/log/mail.log</code></p>
        </div>
    </div>
</body>
</html>
HTML
    
    html
  end
  
  # GET /testing/email/quick - быстрая проверка
  get '/email/quick' do
    content_type :json
    
    result = {
      timestamp: Time.now.strftime('%Y-%m-%d %H:%M:%S'),
      order_email: ENV['ORDER_EMAIL'].to_s,
      order_email_set: !ENV['ORDER_EMAIL'].to_s.empty?,
      delivery_method: (settings.delivery_method rescue 'unknown'),
      environment: PADRINO_ENV,
      host: (request.host rescue 'unknown')
    }
    
    if ENV['ORDER_EMAIL'].to_s.empty?
      result[:status] = 'error'
      result[:message] = 'ORDER_EMAIL не установлена'
      result[:email_sent] = false
    else
      begin
        email do
          from "test@rozariofl.ru"
          to ENV['ORDER_EMAIL'].to_s
          subject "[QUICK TEST] Email система работает"
          body "Быстрый тест email системы прошел успешно.\n\nВремя: #{Time.now}\nСервер: #{request.host rescue 'unknown'}"
        end
        
        result[:status] = 'success'
        result[:message] = "Email отправлен на #{ENV['ORDER_EMAIL']}"
        result[:email_sent] = true
        
        puts "✅ Quick email test sent to #{ENV['ORDER_EMAIL']}"
        
      rescue => e
        result[:status] = 'error'
        result[:message] = "Ошибка отправки: #{e.message}"
        result[:error_class] = e.class.to_s
        result[:email_sent] = false
        
        puts "❌ Quick email test failed: #{e.message}"
      end
    end
    
    result.to_json
  end
  
  # GET /testing/email/detailed - подробная диагностика
  get '/email/detailed' do
    content_type :html
    
    diagnostics = []
    
    # Проверка переменных окружения
    order_email = ENV['ORDER_EMAIL'].to_s
    diagnostics << {
      check: 'ORDER_EMAIL переменная',
      status: order_email.empty? ? 'error' : 'success',
      message: order_email.empty? ? 'Не установлена' : "Установлена: #{order_email}"
    }
    
    # Проверка метода доставки
    delivery_method = settings.delivery_method rescue 'unknown'
    diagnostics << {
      check: 'Delivery Method',
      status: delivery_method == 'unknown' ? 'warning' : 'info',
      message: "Текущий метод: #{delivery_method}"
    }
    
    # Проверка системных команд
    sendmail_available = system("which sendmail > /dev/null 2>&1")
    diagnostics << {
      check: 'Sendmail доступен',
      status: sendmail_available ? 'success' : 'warning',
      message: sendmail_available ? 'Команда sendmail найдена' : 'Команда sendmail не найдена'
    }
    
    # Проверка Postfix
    postfix_running = system("pgrep postfix > /dev/null 2>&1")
    diagnostics << {
      check: 'Postfix процесс',
      status: postfix_running ? 'success' : 'info',
      message: postfix_running ? 'Postfix запущен' : 'Postfix не обнаружен (норма для sendmail)'
    }
    
    # Тест отправки
    email_test_result = nil
    if !order_email.empty?
      begin
        email do
          from "detailed-test@rozariofl.ru"
          to order_email
          subject "[DETAILED TEST] Подробная проверка email"
          body <<-BODY
Подробная проверка email системы Rozario Flowers

=== ДИАГНОСТИКА ===
Время: #{Time.now.strftime('%d.%m.%Y %H:%M:%S')}
Сервер: #{request.host rescue 'неизвестно'}
Environment: #{PADRINO_ENV}
Delivery Method: #{delivery_method}

=== ПРОВЕРКИ ===
#{diagnostics.map { |d| "#{d[:check]}: #{d[:message]}" }.join("\n")}

=== ЗАКЛЮЧЕНИЕ ===
Если вы получили это письмо, система работает корректно.
В случае проблем обратитесь к администратору.
BODY
        end
        
        email_test_result = {
          status: 'success',
          message: "Тестовое письмо отправлено на #{order_email}"
        }
        
        puts "✅ Detailed email test sent to #{order_email}"
        
      rescue => e
        email_test_result = {
          status: 'error',
          message: "Ошибка отправки: #{e.message}",
          error_class: e.class.to_s
        }
        
        puts "❌ Detailed email test failed: #{e.message}"
      end
    else
      email_test_result = {
        status: 'error',
        message: 'ORDER_EMAIL не установлена, отправка невозможна'
      }
    end
    
    html = <<-HTML
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Detailed Email Test</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 20px auto; padding: 20px; }
        .check { padding: 10px; margin: 10px 0; border-radius: 5px; }
        .success { background: #d4edda; color: #155724; border-left: 4px solid #28a745; }
        .error { background: #f8d7da; color: #721c24; border-left: 4px solid #dc3545; }
        .warning { background: #fff3cd; color: #856404; border-left: 4px solid #ffc107; }
        .info { background: #d1ecf1; color: #0c5460; border-left: 4px solid #17a2b8; }
        h1 { color: #333; }
        .result { font-size: 16px; font-weight: bold; margin-top: 30px; }
        a { color: #007cba; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <h1>📋 Подробная диагностика Email системы</h1>
    
    <h2>🔍 Проверки системы:</h2>
HTML
    
    diagnostics.each do |diag|
      html << "<div class=\"check #{diag[:status]}\">\n"
      html << "  <strong>#{diag[:check]}:</strong> #{diag[:message]}\n"
      html << "</div>\n"
    end
    
    html << "\n<h2>📧 Результат отправки тестового письма:</h2>\n"
    html << "<div class=\"check #{email_test_result[:status]} result\">\n"
    html << "  #{email_test_result[:message]}\n"
    if email_test_result[:error_class]
      html << "<br><small>Тип ошибки: #{email_test_result[:error_class]}</small>\n"
    end
    html << "</div>\n"
    
    html << <<-HTML
    
    <div style="margin-top: 40px; text-align: center;">
        <a href="/testing/email">← Назад к тестам</a>
    </div>
</body>
</html>
HTML
    
    html
  end
  
  # GET /testing/email/feedback - тест в стиле отзыва
  get '/email/feedback' do
    content_type :html
    
    if ENV['ORDER_EMAIL'].to_s.empty?
      return <<-HTML
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>Feedback Email Test</title></head>
<body style="font-family: Arial; max-width: 600px; margin: 50px auto; padding: 20px;">
    <div style="background: #f8d7da; color: #721c24; padding: 20px; border-radius: 5px;">
        <h2>❌ Тест невозможен</h2>
        <p>ORDER_EMAIL не установлена. Установите переменную окружения и повторите попытку.</p>
        <a href="/testing/email">← Назад</a>
    </div>
</body></html>
HTML
    end
    
    # Эмулируем данные как в реальном отзыве
    fake_user_name = "Тестовый Пользователь"
    fake_user_email = "test.user@example.com"
    fake_user_id = 12345
    fake_order_id = 87654321
    fake_rating = 5
    fake_review = "Это тестовый отзыв для проверки email системы. Все работает отлично! Спасибо за прекрасные цветы."
    
    begin
      # Формируем письмо точно как в реальной системе отзывов
      order_info = "\nНомер заказа: #{fake_order_id}"
      user_id_info = "\nID пользователя: #{fake_user_id}"
      msg_body = "Имя: #{fake_user_name}\nЭл. почта: #{fake_user_email}\nОтзыв: #{fake_review}\nОценка: #{fake_rating}#{order_info}#{user_id_info}"
      
      email do
        from "no-reply@rozariofl.ru"
        to ENV['ORDER_EMAIL'].to_s
        subject "[TEST] Отзыв с сайта"
        body msg_body
      end
      
      result_html = <<-HTML
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Feedback Email Test Result</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 600px; margin: 50px auto; padding: 20px; }
        .success { background: #d4edda; color: #155724; padding: 20px; border-radius: 5px; border-left: 4px solid #28a745; }
        .details { background: #f8f9fa; padding: 15px; border-radius: 5px; margin: 20px 0; font-family: monospace; font-size: 12px; }
        a { color: #007cba; text-decoration: none; }
    </style>
</head>
<body>
    <div class="success">
        <h2>✅ Тестовый отзыв отправлен!</h2>
        <p>Email в стиле реального отзыва успешно отправлен на <strong>#{ENV['ORDER_EMAIL']}</strong></p>
        <p>Проверьте почту в течение нескольких минут.</p>
    </div>
    
    <h3>📧 Содержимое отправленного письма:</h3>
    <div class="details">
        <strong>От:</strong> no-reply@rozariofl.ru<br>
        <strong>Кому:</strong> #{ENV['ORDER_EMAIL']}<br>
        <strong>Тема:</strong> [TEST] Отзыв с сайта<br><br>
        <strong>Тело письма:</strong><br>
        #{msg_body.gsub("\n", "<br>")}
    </div>
    
    <div style="text-align: center; margin-top: 30px;">
        <a href="/testing/email">← Назад к тестам</a>
    </div>
</body>
</html>
HTML
      
      puts "✅ Feedback-style email test sent to #{ENV['ORDER_EMAIL']}"
      result_html
      
    rescue => e
      puts "❌ Feedback-style email test failed: #{e.message}"
      
      <<-HTML
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>Email Test Error</title></head>
<body style="font-family: Arial; max-width: 600px; margin: 50px auto; padding: 20px;">
    <div style="background: #f8d7da; color: #721c24; padding: 20px; border-radius: 5px; border-left: 4px solid #dc3545;">
        <h2>❌ Ошибка отправки</h2>
        <p><strong>Сообщение:</strong> #{e.message}</p>
        <p><strong>Тип ошибки:</strong> #{e.class}</p>
        <p>Проверьте настройки почтового сервера.</p>
        <a href="/testing/email">← Назад</a>
    </div>
</body></html>
HTML
    end
  end
  
  # POST /testing/email/send - отправка кастомного письма
  post '/email/send' do
    recipient = params[:to].to_s.empty? ? ENV['ORDER_EMAIL'].to_s : params[:to].to_s
    subject = params[:subject].to_s
    body_text = params[:body].to_s
    
    if recipient.empty?
      redirect '/testing/email?error=no_recipient'
      return
    end
    
    if subject.empty? || body_text.empty?
      redirect '/testing/email?error=missing_fields'
      return
    end
    
    begin
      email do
        from "custom-test@rozariofl.ru"
        to recipient
        subject subject
        body body_text
      end
      
      puts "✅ Custom email sent to #{recipient}"
      redirect "/testing/email?success=sent&to=#{recipient}"
      
    rescue => e
      puts "❌ Custom email failed: #{e.message}"
      redirect "/testing/email?error=send_failed&message=#{e.message}"
    end
  end
  
  # Дополнительная проверка для отладки
  get '/email/debug' do
    content_type :json
    
    {
      environment: PADRINO_ENV,
      order_email: ENV['ORDER_EMAIL'],
      all_env: ENV.select { |k, v| k.include?('MAIL') || k.include?('EMAIL') },
      delivery_method: (settings.delivery_method rescue 'unknown'),
      mailer_settings: (settings.mailer rescue {}),
      request_host: request.host,
      current_time: Time.now.iso8601
    }.to_json
  end
end