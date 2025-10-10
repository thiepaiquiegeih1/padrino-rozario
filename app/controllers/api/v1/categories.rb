# encoding: utf-8
Rozario::App.controllers :categories, map: 'api/v1/cat' do
  get 'pages' do
    return ''
    return (CategoriesProducts.where(category_id: params['id']).count / params['cat_page'].to_f).ceil.to_json if params['id'].present?
    return (CategoriesProducts.where(category_id: Category.where(slug: params['name']).first.id).count / params['cat_page'].to_f).ceil.to_json if params['name'].present?
  end
end
