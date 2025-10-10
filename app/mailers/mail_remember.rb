# encoding: utf-8

Rozario::App.mailer :mail_remember do
  email :remember_user do |email, date, surname, image_src, image_url|
    from "Rozario robot <no-reply@#{CURRENT_DOMAIN}>"
    to email
    subject 'Сообщение с сайта RozarioFlowers.Ru'
    locals date: date, surname: surname, image_src: image_src, image_url: image_url
    body render 'mail_remember/remember_user'
    content_type :html
  end
end
