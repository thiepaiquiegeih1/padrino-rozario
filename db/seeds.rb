# encoding: utf-8
# Seed add you the ability to populate your db.
# We provide you a basic shell for interaction with the end user.
# So try some code like below:
#
#   name = shell.ask("What's your name?")
#   shell.say name
#
email     = shell.ask "Which email do you want use for logging into admin?"
password  = shell.ask "Tell me the password to use:"

shell.say ""

account = Account.create(:email => email, :name => "Foo", :surname => "Bar", :password => password, :password_confirmation => password, :role => "admin")

if account.valid?
  shell.say "================================================================="
  shell.say "Account has been successfully created, now you can login with:"
  shell.say "================================================================="
  shell.say "   email: #{email}"
  shell.say "   password: #{password}"
  shell.say "================================================================="
else
  shell.say "Sorry but some thing went wrong!"
  shell.say ""
  account.errors.full_messages.each { |m| shell.say "   - #{m}" }
end

shell.say ""

# Create SEO general settings for smiles pages
smiles_seo = SeoGeneral.find_or_create_by(name: 'smiles') do |seo|
  seo.title = 'Фото доставки цветов - Отзывы клиентов'
  seo.description = 'Посмотрите фотографии наших работ - реальные отзывы клиентов с фото доставленных букетов. Качественная доставка цветов с гарантией.'
  seo.keywords = 'фото доставки цветов, отзывы с фото, букеты доставка, цветы фото'
  seo.h1 = 'Фото доставки цветов'
  seo.h2 = 'Отзывы наших клиентов'
  seo.og_type = 'website'
  seo.og_title = 'Фото доставки цветов - Отзывы клиентов с фотографиями'
  seo.og_description = 'Посмотрите фотографии наших работ - реальные отзывы клиентов с фото доставленных букетов.'
  seo.og_site_name = 'Rozario Flowers'
  seo.twitter_title = 'Фото доставки цветов - Отзывы клиентов'
  seo.twitter_description = 'Посмотрите фотографии наших работ - реальные отзывы клиентов.'
  seo.twitter_site = '@rozarioflowers'
  seo.twitter_image_alt = 'Фото доставки цветов'
  seo.index = true
  seo.url = '/smiles/'
  seo.page = true
end

if smiles_seo.persisted?
  puts "✓ SEO настройки для smiles созданы/обновлены"
else
  puts "✗ Ошибка создания SEO настроек для smiles: #{smiles_seo.errors.full_messages.join(', ')}"
end