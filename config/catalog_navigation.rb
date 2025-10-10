# encoding: utf-8
SimpleNavigation::Configuration.run do |navigation|

  navigation.items do |primary|
    primary.item :company, 'О компании', '/page/company'
    primary.item :dostavka, 'Доставка', '/page/dostavka'
    primary.item :oplata, 'Оплата', '/page/opl'
    primary.item :predopl, 'Предоплата', '/page/predopl'
    primary.item :comment, 'Отзывы', '/comment'
    primary.item :article, 'Статьи', '/article'
    primary.item :contacts, 'Контактная информация', '/page/contacts'
   end

end