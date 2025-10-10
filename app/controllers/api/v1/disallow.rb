# encoding: utf-8
Rozario::App.controllers :disallow, map: 'api/v1/disallow' do
  get :index do
    content_type :json
    pages = [ # Список страниц для индексации
      { name: 'article',  type: Article  },
      { name: 'page',     type: Page     },
      { name: 'category', type: Category },
      { name: 'product',  type: Product  },
      { name: 'news',     type: News     },
      { name: 'smile',    type: Smile    }
    ]
    res = []
    indexed(pages, allow=false).each { |page| res.push(page) }
    return res.to_json
  end
end
