# encoding: utf-8

def get_path(page, x)
  if page[:name] == 'category' then # Генерация пути для страницы категории с учетом уровня
    if (x.level > 1) # Для категорий с уровнем больше 1, получаем родительскую категорию
      parent_category = Category.find(x.parent_id)
      path = "#{page[:name]}/#{parent_category.slug ? parent_category.slug : parent_category.id.to_s}/#{x.slug ? x.slug : x.id.to_s}"
    else; path = "#{page[:name]}/#{x.slug ? x.slug : x.id.to_s}"; end 
  else; path = page[:name] + '/' + (x.slug ? x.slug.to_s : x.id.to_s); end
  return path
end

def indexed(pages, allow=true)
  res = []
  pages.each { |page|
    page[:type].includes(:seo).where(seos: {index: allow}).all.each { |x|
      res.push(get_path(page, x))
    }
  }
  return res
end

def main_pages()
  res = ''
  SeoGeneral.where(page: 1, index: true).all.each { |x| res += 'Allow: ' + x.url + "$\n" }
  return res
end
