# encoding: utf-8
Rozario::Admin.controllers :disabled_dates do
  get :index do
    @title = "Disabled dates"
    @disabled_date = DisabledDate.order('enabled DESC, date DESC').paginate(:page => params[:page], :per_page => 20)
    render 'disabled_dates/index'
  end

  get :new do
    @title = pat(:new_title, :model => 'disabled_date')
    @disabled_date = DisabledDate.new
    @subdomains = Subdomain.order('city ASC').all.map{|s| {id: s.id, name: s.city+" ("+s.url+")"}}
    subdomain = Subdomain.order('city ASC').joins(:disabled_dates).all
    @selected = []
    render 'disabled_dates/new'
  end

  post :create do
    @disabled_date = DisabledDate.new(params[:disabled_date].except("subdomains"))
    @subdomains = Subdomain.order('city ASC').all.map{|s| {id: s.id, name: s.city+" ("+s.url+")"}}
    subdomains = params[:disabled_date][:subdomains]
    if @disabled_date.save
      if subdomains.present? && subdomains.count(",") > 0
          @disabled_date.subdomain << Subdomain.find(subdomains.split(','))
      elsif subdomains.present?
        subb = Subdomain.find(subdomains)
        subb.disabled_dates << @disabled_date
      end
      @title = pat(:create_title, :model => "disabled_date #{@disabled_date.id}")
      flash[:success] = pat(:create_success, :model => 'DisabledDate')
      params[:save_and_continue] ? redirect(url(:disabled_dates, :index)) : redirect(url(:disabled_dates, :edit, :id => @disabled_date.id))
    else
      @title = pat(:create_title, :model => 'disabled_date')
      flash.now[:error] = pat(:create_error, :model => 'число')
      render 'disabled_dates/new'
    end
  end

  get :edit, :with => :id do
    @selected = []
    @title = pat(:edit_title, :model => "disabled_date #{params[:id]}")
    @disabled_date = DisabledDate.find(params[:id])
    @subdomains = Subdomain.order('city ASC').all.map{|s| {id: s.id, name: s.city+" ("+s.url+")"}}
    subdomain = Subdomain.order('city ASC').joins(:disabled_dates).all
    @selected = @disabled_date.subdomain.map { |d| {id: d.id, name: (d.city + " (" + d.url + ")")} }
    render 'disabled_dates/edit'
    if @disabled_date
      render 'disabled_dates/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'disabled_date', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "disabled_date #{params[:id]}")
    @disabled_date = DisabledDate.find(params[:id])
    subdomains = params[:disabled_date][:subdomains]
    if @disabled_date
      if @disabled_date.update_attributes(params[:disabled_date].except("subdomains"))
        @disabled_date.subdomain.delete_all
        if subdomains.present? && subdomains.count(",") > 0
            @disabled_date.subdomain << Subdomain.find(subdomains.split(','))
        elsif subdomains.present?
          subb = Subdomain.find(subdomains)
          subb.disabled_dates << @disabled_date
        end

        flash[:success] = pat(:update_success, :model => 'DisabledDate', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:disabled_dates, :index)) :
          redirect(url(:disabled_dates, :edit, :id => @disabled_date.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'disabled_dates')
        render 'disabled_dates/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'disabled_date', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "DisabledDate"
    disabled_date = DisabledDate.find(params[:id])
    if disabled_date
      if disabled_date.destroy
        flash[:success] = pat(:delete_success, :model => 'DisabledDate', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'disabled_date')
      end
      redirect url(:disabled_dates, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'disabled_dates', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Disabled dates"
    unless params[:disabled_date_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'disabled_date')
      redirect(url(:disabled_dates, :index))
    end
    ids = params[:disabled_date_ids].split(',').map(&:strip).map(&:to_i)
    disabled_date = DisabledDate.find(ids)

    if DisabledDate.destroy disabled_date

      flash[:success] = pat(:destroy_many_success, :model => 'DisabledDate', :ids => "#{ids.to_sentence}")
    end
    redirect url(:disabled_dates, :index)
  end

  get :search do
    type = params['type']
    query = strip_tags(params[:query]).mb_chars.downcase

    if params[:query].length > 0
      @disabled_date = DisabledDate.where("#{type} like ?", "%#{query}%").all.paginate(:page => params[:page], :per_page => 20)
      if @disabled_date.first.nil?
        flash[:error] = "Ничего не найдено :("
        redirect back
      else
        flash[:success] = "Найдено"
        render 'disabled_date/index'
      end
    else
      @disabled_date = DisabledDate.order('created_at DESC').paginate(:page => params[:page], :per_page => 20)
      flash[:error] = "Введите запрос"
      render 'disabled_date/index'
    end
  end
end
