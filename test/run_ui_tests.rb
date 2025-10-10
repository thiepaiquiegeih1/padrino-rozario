#!/usr/bin/env ruby
# encoding: utf-8

# Простой скрипт для запуска UI тестов
# Использование: ruby test/run_ui_tests.rb

require 'webrick'
require 'launchy' # gem install launchy для автоматического открытия браузера

class UITestRunner
  def self.run(port = 8080)
    test_dir = File.dirname(__FILE__)
    
    puts "🌟 Запуск UI тестов Rozario Flowers"
    puts "📁 Папка тестов: #{test_dir}"
    puts "🌐 Сервер будет доступен по адресу: http://localhost:#{port}"
    puts "📋 Доступные тесты:"
    
    # Найти все HTML тестовые файлы
    test_files = Dir.glob(File.join(test_dir, '*.html'))
    test_files.each_with_index do |file, index|
      filename = File.basename(file)
      puts "   #{index + 1}. #{filename}"
    end
    
    if test_files.empty?
      puts "❌ Тестовые файлы не найдены!"
      exit 1
    end
    
    puts "\n🚀 Запуск HTTP сервера..."
    
    # Настройка WEBrick сервера
    server = WEBrick::HTTPServer.new(
      :Port => port,
      :DocumentRoot => test_dir,
      :Logger => WEBrick::Log.new('/dev/null'),
      :AccessLog => []
    )
    
    # Обработка Ctrl+C для корректного завершения
    trap('INT') do
      puts "\n🛑 Остановка сервера..."
      server.shutdown
    end
    
    # Автоматическое открытие браузера (если установлен launchy)
    Thread.new do
      sleep 2
      main_test_url = "http://localhost:#{port}/#{File.basename(test_files.first)}"
      
      begin
        require 'launchy'
        puts "🌐 Открытие браузера: #{main_test_url}"
        Launchy.open(main_test_url)
      rescue LoadError
        puts "💡 Для автоматического открытия браузера установите: gem install launchy"
        puts "🌐 Откройте в браузере: #{main_test_url}"
      rescue => e
        puts "🌐 Откройте в браузере: #{main_test_url}"
      end
    end
    
    puts "✅ Сервер запущен! Нажмите Ctrl+C для остановки."
    
    # Запуск сервера
    server.start
  rescue => e
    puts "❌ Ошибка запуска сервера: #{e.message}"
    exit 1
  end
end

# Запуск если файл выполняется напрямую
if __FILE__ == $0
  port = ARGV[0] ? ARGV[0].to_i : 8080
  UITestRunner.run(port)
end