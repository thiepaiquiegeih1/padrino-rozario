# encoding: utf-8
Rozario::Admin.controllers :smiles do

  get :index do
    filter = params[:filter]
    @title = "Улыбки наших покупателей"
    #@slideshows = Slideshow.all
    if filter == "sidebar"
      @smile = Smile.where(sidebar: true).all.paginate(:page => params[:page], :per_page => 20)
      render 'smiles/index'
    end

    @smile = Smile.order('sidebar DESC, created_at DESC').paginate(:page => params[:page], :per_page => 20)
    render 'smiles/index'
  end

  get :new do
    @title = pat(:new_title, :model => 'smile')

    @product = []
    product  = Product.pluck(:id).map(&:to_s).zip(Product.pluck(:header).map(&:to_s))
    product.each do |id, name|
      @product += [id.to_s + " - " + name.to_s]
    end
    @smile = Smile.new
    @smile.seo = Seo.new
    render 'smiles/new'
  end

  post :create do
    json_order = params[:smile][:order]
    hash = {}
    @smile = Smile.new(params[:smile].except("order"))
    @smile[:slug] = @smile[:title].to_lat unless @smile[:slug].present?
    json_order[:products_names].each.with_index do |j, i|
      hash[i] = [["id", j[1].split(' - ')[0]], ["complect", json_order[:products_components][i.to_s]]].to_h if j[1].present?
    end
    @smile[:json_order] = hash.to_json
    if @smile.save
      @title = pat(:create_title, :model => "smile #{@smile.id}")
      flash[:success] = pat(:create_success, :model => 'Smile')
      params[:save_and_continue] ? redirect(url(:smiles, :index)) : redirect(url(:smiles, :edit, :id => @smile.id))
    else
      @title = pat(:create_title, :model => 'smile')
      flash.now[:error] = pat(:create_error, :model => 'smile')
      render 'smiles/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "smiles #{params[:id]}")
    @smile = Smile.find(params[:id])
    @smile.seo = Seo.new unless @smile.seo.present?
    @product = []
    product  = Product.all
    product.each do |p|
      @product += [p.id.to_s + " - " + p.header.to_s]
    end
    @json_order = {}
    @product_n = []
    @product_c = []
    if @smile
      JSON.parse(@smile.json_order).each do |num, o|
        name = o['id'].to_s + " - " + Product.find(o['id']).header
        @json_order[num] = {name: name, component: o['complect']}
        @product_n[num.to_i] = name
        @product_c[num.to_i] = o['complect']
      end
      render 'smiles/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'smile', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    json_order = params[:smile][:order]
    @title = pat(:update_title, :model => "smile #{params[:id]}")
    @smile = Smile.find(params[:id])
    hash = {}
    if json_order
      json_order[:products_names].each.with_index do |j, i|
        hash[i] = [["id", j[1].split(' - ')[0]], ["complect", json_order[:products_components][i.to_s]]].to_h if j[1].present?
      end
      params[:smile][:json_order] = hash.to_json
    end
    if @smile
      if @smile.update_attributes(params[:smile].except("order"))
        flash[:success] = pat(:update_success, :model => 'Smile', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:smiles, :index)) :
          redirect(url(:smiles, :edit, :id => @smile.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'smiles')
        render 'smiles/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'smile', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Smile"
    smile = Smile.find(params[:id])
    if smile
      if smile.destroy
        flash[:success] = pat(:delete_success, :model => 'Smile', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'smile')
      end
      redirect url(:smiles, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'smiles', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Smiles"
    unless params[:smile_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'smile')
      redirect(url(:smiles, :index))
    end
    ids = params[:smile_ids].split(',').map(&:strip).map(&:to_i)
    smile = Smile.find(ids)

    if Smile.destroy smile

      flash[:success] = pat(:destroy_many_success, :model => 'Smile', :ids => "#{ids.to_sentence}")
    end
    redirect url(:smiles, :index)
  end

  get :search do
    type = params['type']
    query = strip_tags(params[:query]).mb_chars.downcase

    if params[:query].length > 0
      @smile = Smile.where("#{type} like ?", "%#{query}%").all.paginate(:page => params[:page], :per_page => 20)
      if @smile.first.nil?
        flash[:error] = "Ничего не найдено :("
        redirect back
      else
        flash[:success] = "Найдено"
        render 'smiles/index'
      end
    else
      @smile = Smile.order('created_at DESC').paginate(:page => params[:page], :per_page => 20)
      flash[:error] = "Введите запрос"
      render 'smiles/index'
    end
  end
end
