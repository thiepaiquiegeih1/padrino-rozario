# encoding: utf-8
Rozario::App.controllers :category do

  require 'will_paginate/array'

  get 'recheck' do
    @done = "error"
    Product.find_each do |product|
      if not product.categories.map {|cat| cat.id }.include? 63
        product.small_price = 0
        product.lux_price = 0
        product.save!
      end
    end
    @done = "ok"
  end

  get :index do
    @categories = @subdomain ? @subdomain.enable_categories ? Category.where(id: @all_cats.pluck(:id)) : nil : Category.all
    @canonical = "https://#{request.env['HTTP_HOST']}/category"
    get_seo_data('categories_page', nil, true)
    render 'category/index'
  end

  get :oldbukets do
    @category = Category.find_by_id(55)
    @all = params[:all]
    @items = @category.products.order('created_at DESC')
    @sorting = params[:sorting]
    unless @sorting.blank?
      if params[:sorting] == 'price-desc'
        #@items = @items.sort { |a,b| b.price.to_i <=> a.price.to_i }
        @items = @items.reorder("price DESC")
      elsif params[:sorting] == 'price-asc'
        #@items = @items.sort { |a,b| a.price.to_i <=> b.price.to_i }
        @items = @items.reorder("price ASC")
      else
        #@items = @items.sort { |a,b| a.title.to_s <=> b.title.to_s }
        @items = @category.products.reorder("header ASC")
      end
    end

    @items = @all.blank? ? @items.paginate(:page => params[:page], :per_page => 21) : @items
    if @category.blank?
      error 404
    end

    @childrens = Category.where(:parent_id => @category.id)
    render 'category/subcats_only'
  end

  get :index, with: :slug do
    if params[:slug] != 'promotions'
      process_slug(params)
    else
      process_promotions(params)
    end
  end

  get '/:parent_slug/:slug' do
    process_slug(params)
  end

  helpers do
    def process_slug(params) # Общий метод для обработки
      if Category.find_by_slug(params[:slug].force_encoding('UTF-8')).present?; cat_id = Category.find_by_slug(params[:slug].force_encoding('UTF-8')).id
      else;                                                                     cat_id = Category.find(params[:slug].force_encoding('UTF-8')).id; end
      @canonical = "https://#{request.env['HTTP_HOST']}/category/#{Category.find(cat_id).slug.force_encoding('UTF-8')}" if Category.find(cat_id).slug
      if    cat_id.to_i == 0;   id_ctgr = Category.where(slug: params[:slug].force_encoding('UTF-8'))[0]['id']
      elsif cat_id.to_i == 101; id_ctgr = 733
      else;                     id_ctgr = cat_id.to_i; end
      if request.session[:mdata].nil?
        current_date = Date.current
        session[:mdata] = Date.current
      else
        current_date = request.session[:mdata]
        session[:mdata] = request.session[:mdata]
      end
      @sess = session[:mdata]
      if @subdomain.enable_categories
        category_ids = @all_cats.pluck(:id)
        if id_ctgr.to_i.in? @all_cats.pluck(:id); @category = Category.find(id_ctgr)
        else; error 404; end
        categories = if params[:categories].blank? || params[:categories].empty?
          [@category.id]
        else
          params[:categories] if params[:categories].to_i.in? category_ids
        end
        @childrens = Category.where(parent_id: @category.id).where(id: @all_cats.pluck(:id))
      elsif @subdomain_pool.enable_categories
        category_ids = @all_cats.pluck(:id)
        if id_ctgr.to_i.in? @all_cats.pluck(:id); @category = Category.find(id_ctgr)
        else; error 404; end
        categories = if params[:categories].blank? || params[:categories].empty?
          [@category.id]
        else
          params[:categories] if params[:categories].to_i.in? category_ids
        end
        @childrens = Category.where(parent_id: @category.id).where(id: @all_cats.pluck(:id))
      else
        @category = Category.find(id_ctgr)
        if @category.blank?; error 404; end
        @category = Category.find(118)  if @category.id == 55
        categories = if params[:categories].blank? || params[:categories].empty?
          if (params[:tags].blank? || params[:tags].empty?) && params[:min_price].blank? && params[:max_price].blank?
            [@category.id] #.concat Category.where(parent_id: (@category.id == 118 ? 55 : @category.id) ).select('id').map(&:id)
          else
            [@category.id, 55, 63, 64, 65] #.concat Category.where(parent_id: (@category.id == 118 ? 55 : @category.id) ).select('id').map(&:id)
          end
        else
          params[:categories].to_i
        end
        @childrens = Category.where(parent_id: @category.id)
      end

      @tags = Tag.where(infilters: true)
      @vidy = Category.vidy
      @limit = 30
      page = params[:page] ? params[:page].to_i : 0

      min_price = params[:min_price].blank? ? 0         : params[:min_price].to_i
      max_price = params[:max_price].blank? ? 1_000_000 : params[:max_price].to_i

      @items = Product.get_catalog(
        @subdomain, @subdomain_pool,
        categories, params[:tags],
        min_price, max_price,
        params[:sort_by]
      )

      page = 0 if page < 0

      @need_pagination = @items.count > @limit
      @items = @items.drop(@limit * page).take(@limit)

      if request.xhr?; render 'category/withfilters', layout: false
      else
        if !@category.template.nil? || !@category.template.empty?
          temp = @category.template.empty? ? 'index' : @category.template
          temp = temp == 'subcats_only' ? 'perekrestok' : temp
          x = ActiveRecord::Base.connection.execute("SELECT * from texts WHERE category=" + @category.id.to_s).to_a
          if x.present?
            @text = x[0][1] ? x[0][1].html_safe : ''
            @h1 = x[0][2].present? ? x[0][2].html_safe : ''
            if x[0][3].present?
              markdown = x[0][3]
              @text = markdown_to_html(markdown)
            end
            @text = @text.gsub(/%morph_datel%/, @subdomain.morph_datel).gsub(/%morph_predl%/, @subdomain.morph_predl).gsub(/%city%/, @subdomain.city).gsub(/%morph_rodit%/, @subdomain.morph_rodit).html_safe
          end
          get_seo_data('categories', Category.find_by_id(cat_id).seo_id, true)
          render "category/#{temp}", layout: 'catalog'
          # redirect '/'
        else
          render 'category/index', layout: 'catalog'
        end
      end
    end
    def process_promotions(params)
      begin
        if Category.find_by_slug(params[:slug].force_encoding('UTF-8')).present?; cat_id = Category.find_by_slug(params[:slug].force_encoding('UTF-8')).id
        else;                                                                     cat_id = Category.find(params[:slug].force_encoding('UTF-8')).id; end
        @canonical = "https://#{request.env['HTTP_HOST']}/category/#{Category.find(cat_id).slug.force_encoding('UTF-8')}" if Category.find(cat_id).slug
        @category = Category.find(cat_id)
        @items = Product.get_catalog(@subdomain, @subdomain_pool)
        @limit = 30
        # product_ids = []; current_time = Time.now
        # ProductComplect.where("discounts IS NOT NULL AND discounts != '' AND discounts != '[]' AND discounts != '[]\n' AND discounts != '\n'").each do |product_сomplect|
        #   begin
        #     JSON.parse(product_сomplect.discounts).each do |discount|
        #       percent    = discount["percent"] || 0
        #       cap        = discount["cap"]     || 0
        #       shedule    = discount["shedule"] || '* * * * *'
        #       start_time = convert_to_utc_plus_3(discount["period"]["datetime_start"])
        #       end_time   = convert_to_utc_plus_3(discount["period"]["datetime_end"])
        #       if percent > 0 && matches_cron?(shedule) && start_time <= current_time && current_time <= end_time # Проверяем, входит ли текущее время в промежуток
        #         # result = {
        #         #   percent: percent,
        #         #   cap: cap,
        #         #   shedule: shedule,
        #         #   period: {
        #         #     datetime_start: discount["period"]["datetime_start"],
        #         #     datetime_end: discount["period"]["datetime_end"]
        #         #   }
        #         # }
        #         # product_сomplect.discounts = result.to_json
        #         unless product_ids.include?(product_сomplect.product_id)
        #           product_ids.append(product_сomplect.product_id)
        #         end
        #       end
        #     end
        #   rescue # StandardError => e
        #     next
        #   end
        # end
        # @items = @items.where(id: product_ids.uniq!)
        render 'category/withinfo', layout: 'catalog'
      rescue # StandardError => e
        if PADRINO_ENV == 'development'; error 404
        else;                            raise; end
      end
    end
  end
end
