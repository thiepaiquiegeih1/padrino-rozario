# encoding: utf-8
SimpleNavigation::Configuration.run do |navigation|

  navigation.items do |primary|
    primary.item :company,  'О компании',            host_url('/page/company')
    primary.item :dostavka, 'Доставка',              host_url('/page/dostavka') 
    primary.item :oplata,   'Оплата',                host_url('/page/opl') 
    primary.item :oplata,   'Предоплата',            host_url('/page/predopl') 
    primary.item :comment,  'Отзывы',                host_url('/comment')
    primary.item :article,  'Статьи',                host_url('/article')
    primary.item :contacts, 'Контактная информация', host_url('/page/contacts')
  end

#primary.item :books, 'Books', books_path, :id => 'my_special_id'

end
