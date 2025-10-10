# encoding: utf-8
namespace :mail do
  desc 'Send remember emails'
  task :remember => :environment do
    Rozario::App.controllers :test do
      slideshow = Slideshow.where(:default => true).first
      slide = slideshow.slides.first
      image_src = slide.image.to_s
      image_url = slide.uri.empty? ? nil : slide.uri
      remembers = Remember.where(notificate_at: Date.today)
      h = {}
      remembers.each do |remember|
        h[remember.user_account_id] = remember
      end
      h.values.each do |remember|
        account = UserAccount.find(remember.user_account_id)
        date = remember.order_date
        deliver(:mail_remember, :remember_user, account.email, date, account.surname, image_src, image_url)
      end
    end
  end

  desc 'Test emails'
  task :test => :environment do
    Rozario::App.controllers :test do
      slideshow = Slideshow.where(:default => true).first
      slide = slideshow.slides.first
      image_src = slide.image.to_s
      image_url = slide.uri.empty? ? nil : slide.uri
      remember = Remember.last
      account = UserAccount.find(remember.user_account_id)
      date = remember.order_date
      deliver(:mail_remember, :remember_user, 'vodafon.ua@gmail.com', date, account.surname, image_src, image_url)
    end
  end
end
