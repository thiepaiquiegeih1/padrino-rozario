# encoding: utf-8
Rozario::Admin.controllers :delivery do
  get :index do
    redirect url('delivery/murmanskstreets', :index)
  end

  Rozario::Admin.controllers :'delivery/murmanskstreets' do
    get :index do
      @title = "Murmanskstreets"
      @murmanskstreets = Murmanskstreet.order('name').paginate(:page => params[:page], :per_page => 20)
      render 'delivery/murmanskstreets/index'
    end

    get :new do
      @title = pat(:new_title, :model => 'murmanskstreet')
      @murmanskstreet = Murmanskstreet.new
      render 'delivery/murmanskstreets/new'
    end

    post :create do
      @murmanskstreet = Murmanskstreet.new(params[:murmanskstreet])
      if @murmanskstreet.save
        @title = pat(:create_title, :model => "murmanskstreet #{@murmanskstreet.id}")
        flash[:success] = pat(:create_success, :model => 'Murmanskstreet')
        params[:save_and_continue] ? redirect(url(:'delivery/murmanskstreets', :index)) : redirect(url(:'delivery/murmanskstreets', :edit, :id => @murmanskstreet.id))
      else
        @title = pat(:create_title, :model => 'murmanskstreet')
        flash.now[:error] = pat(:create_error, :model => 'murmanskstreet')
        render 'delivery/murmanskstreets/new'
      end
    end

    get :edit, :with => :id do
      @title = pat(:edit_title, :model => "murmanskstreet #{params[:id]}")
      @murmanskstreet = Murmanskstreet.find(params[:id])
      if @murmanskstreet
        render 'delivery/murmanskstreets/edit'
      else
        flash[:warning] = pat(:create_error, :model => 'murmanskstreet', :id => "#{params[:id]}")
        halt 404
      end
    end

    put :update, :with => :id do
      @title = pat(:update_title, :model => "murmanskstreet #{params[:id]}")
      @murmanskstreet = Murmanskstreet.find(params[:id])
      if @murmanskstreet
        if @murmanskstreet.update_attributes(params[:murmanskstreet])
          flash[:success] = pat(:update_success, :model => 'Murmanskstreet', :id =>  "#{params[:id]}")
          params[:save_and_continue] ?
            redirect(url(:'delivery/murmanskstreets', :index)) :
            redirect(url(:'delivery/murmanskstreets', :edit, :id => @murmanskstreet.id))
        else
          flash.now[:error] = pat(:update_error, :model => 'murmanskstreet')
          render 'delivery/murmanskstreets/edit'
        end
      else
        flash[:warning] = pat(:update_warning, :model => 'murmanskstreet', :id => "#{params[:id]}")
        halt 404
      end
    end

    delete :destroy, :with => :id do
      @title = "Murmanskstreets"
      murmanskstreet = Murmanskstreet.find(params[:id])
      if murmanskstreet
        if murmanskstreet.destroy
          flash[:success] = pat(:delete_success, :model => 'Murmanskstreet', :id => "#{params[:id]}")
        else
          flash[:error] = pat(:delete_error, :model => 'murmanskstreet')
        end
        redirect url(:'delivery/murmanskstreets', :index)
      else
        flash[:warning] = pat(:delete_warning, :model => 'murmanskstreet', :id => "#{params[:id]}")
        halt 404
      end
    end

    delete :destroy_many do
      @title = "Murmanskstreets"
      unless params[:murmanskstreet_ids]
        flash[:error] = pat(:destroy_many_error, :model => 'murmanskstreet')
        redirect(url(:'delivery/murmanskstreets', :index))
      end
      ids = params[:murmanskstreet_ids].split(',').map(&:strip).map(&:to_i)
      murmanskstreets = Murmanskstreet.find(ids)

      if Murmanskstreet.destroy murmanskstreets

        flash[:success] = pat(:destroy_many_success, :model => 'Murmanskstreets', :ids => "#{ids.to_sentence}")
      end
      redirect url(:'delivery/murmanskstreets', :index)
    end

    get :search do
      query = strip_tags(params[:query]).mb_chars.downcase
      if query.length >= 3
        @murmanskstreets = Murmanskstreet.where("lower(name) like ?", "%#{query}%").all
        if @murmanskstreets.first.nil?
          flash[:error] = "Ничего не найдено :("
          redirect back
        else
          @search = true
          render 'delivery/murmanskstreets/index'
        end
      end
    end

  end

  Rozario::Admin.controllers :'delivery/subdomains' do
    get :index do
      @title = "Города"
      @subdomains = Subdomain.order('city').paginate(:page => params[:page], :per_page => 20)
      @search = false
      render 'delivery/subdomains/index'
    end

    get :edit, :with => :id do
      @title = pat(:edit_title, :model => "subdomain #{params[:id]}")
      @subdomain = Subdomain.find(params[:id])
      if @subdomain
        render 'delivery/subdomains/edit'
      else
        flash[:warning] = pat(:create_error, :model => 'subdomain', :id => "#{params[:id]}")
        halt 404
      end
    end

    put :update, :with => :id do
      @title = pat(:update_title, :model => "subdomain #{params[:id]}")
      @subdomain = Subdomain.find(params[:id])
      if @subdomain
        if @subdomain.update_attributes(params[:subdomain])
          flash[:success] = pat(:update_success, :model => 'Subdomain', :id =>  "#{params[:id]}")
          params[:save_and_continue] ?
            redirect(url(:'delivery/subdomains', :index)) :
            redirect(url(:'delivery/subdomains', :edit, :id => @subdomain.id))
        else
          flash.now[:error] = pat(:update_error, :model => 'subdomain')
          render 'delivery/subdomains/edit'
        end
      else
        flash[:warning] = pat(:update_warning, :model => 'subdomain', :id => "#{params[:id]}")
        halt 404
      end
    end

    get :search do
      query = strip_tags(params[:query]).mb_chars.downcase
      if query.length >= 3
        @subdomains = Subdomain.where("lower(city) like ?", "%#{query}%").all
        if @subdomains.first.nil?
          flash[:error] = "Ничего не найдено :("
          redirect back
        else
          @search = true
          render 'delivery/subdomains/index'
        end
      end
    end

  end

  Rozario::Admin.controllers :'delivery/overtime_deliveries' do
    get :index do
      @title = "Overtime_deliveries"
      @overtime_deliveries = OvertimeDelivery.all
      render 'delivery/overtime_deliveries/index'
    end

    get :new do
      @title = pat(:new_title, :model => 'overtime_delivery')
      @overtime_delivery = OvertimeDelivery.new
      render 'delivery/overtime_deliveries/new'
    end

    post :create do
      @overtime_delivery = OvertimeDelivery.new(params[:overtime_delivery])
      if @overtime_delivery.save
        @title = pat(:create_title, :model => "overtime_delivery #{@overtime_delivery.id}")
        flash[:success] = pat(:create_success, :model => 'OvertimeDelivery')
        params[:save_and_continue] ? redirect(url(:'delivery/overtime_deliveries', :index)) : redirect(url(:'delivery/overtime_deliveries', :edit, :id => @overtime_delivery.id))
      else
        @title = pat(:create_title, :model => 'overtime_delivery')
        flash.now[:error] = pat(:create_error, :model => 'overtime_delivery')
        render 'delivery/overtime_deliveries/new'
      end
    end

    get :edit, :with => :id do
      @title = pat(:edit_title, :model => "overtime_delivery #{params[:id]}")
      @overtime_delivery = OvertimeDelivery.find(params[:id])
      if @overtime_delivery
        render 'delivery/overtime_deliveries/edit'
      else
        flash[:warning] = pat(:create_error, :model => 'overtime_delivery', :id => "#{params[:id]}")
        halt 404
      end
    end

    put :update, :with => :id do
      @title = pat(:update_title, :model => "overtime_delivery #{params[:id]}")
      @overtime_delivery = OvertimeDelivery.find(params[:id])
      if @overtime_delivery
        if @overtime_delivery.update_attributes(params[:overtime_delivery])
          flash[:success] = pat(:update_success, :model => 'Overtime_delivery', :id =>  "#{params[:id]}")
          params[:save_and_continue] ?
            redirect(url(:'delivery/overtime_deliveries', :index)) :
            redirect(url(:'delivery/overtime_deliveries', :edit, :id => @overtime_delivery.id))
        else
          flash.now[:error] = pat(:update_error, :model => 'overtime_delivery')
          render 'delivery/overtime_deliveries/edit'
        end
      else
        flash[:warning] = pat(:update_warning, :model => 'overtime_delivery', :id => "#{params[:id]}")
        halt 404
      end
    end

    delete :destroy, :with => :id do
      @title = "Overtime_deliveries"
      overtime_delivery = OvertimeDelivery.find(params[:id])
      if overtime_delivery
        if overtime_delivery.destroy
          flash[:success] = pat(:delete_success, :model => 'Overtime_delivery', :id => "#{params[:id]}")
        else
          flash[:error] = pat(:delete_error, :model => 'overtime_delivery')
        end
        redirect url(:'delivery/overtime_deliveries', :index)
      else
        flash[:warning] = pat(:delete_warning, :model => 'overtime_delivery', :id => "#{params[:id]}")
        halt 404
      end
    end

    delete :destroy_many do
      @title = "Overtime_deliveries"
      unless params[:overtime_delivery_ids]
        flash[:error] = pat(:destroy_many_error, :model => 'overtime_delivery')
        redirect(url(:'delivery/overtime_deliveries', :index))
      end
      ids = params[:overtime_delivery_ids].split(',').map(&:strip).map(&:to_i)
      overtime_deliveries = OvertimeDelivery.find(ids)

      if OvertimeDelivery.destroy overtime_deliveries

        flash[:success] = pat(:destroy_many_success, :model => 'Overtime_deliveries', :ids => "#{ids.to_sentence}")
      end
      redirect url(:'delivery/overtime_deliveries', :index)
    end
  end

  Rozario::Admin.controllers :'delivery/overtime_deliveries' do
    get :index do
      @title = "Overtime_deliveries"
      @overtime_deliveries = OvertimeDelivery.all
      render 'delivery/overtime_deliveries/index'
    end

    get :new do
      @title = pat(:new_title, :model => 'overtime_delivery')
      @overtime_delivery = OvertimeDelivery.new
      render 'delivery/overtime_deliveries/new'
    end

    post :create do
      @overtime_delivery = OvertimeDelivery.new(params[:overtime_delivery])
      if @overtime_delivery.save
        @title = pat(:create_title, :model => "overtime_delivery #{@overtime_delivery.id}")
        flash[:success] = pat(:create_success, :model => 'OvertimeDelivery')
        params[:save_and_continue] ? redirect(url(:'delivery/overtime_deliveries', :index)) : redirect(url(:'delivery/overtime_deliveries', :edit, :id => @overtime_delivery.id))
      else
        @title = pat(:create_title, :model => 'overtime_delivery')
        flash.now[:error] = pat(:create_error, :model => 'overtime_delivery')
        render 'delivery/overtime_deliveries/new'
      end
    end

    get :edit, :with => :id do
      @title = pat(:edit_title, :model => "overtime_delivery #{params[:id]}")
      @overtime_delivery = OvertimeDelivery.find(params[:id])
      if @overtime_delivery
        render 'delivery/overtime_deliveries/edit'
      else
        flash[:warning] = pat(:create_error, :model => 'overtime_delivery', :id => "#{params[:id]}")
        halt 404
      end
    end

    put :update, :with => :id do
      @title = pat(:update_title, :model => "overtime_delivery #{params[:id]}")
      @overtime_delivery = OvertimeDelivery.find(params[:id])
      if @overtime_delivery
        if @overtime_delivery.update_attributes(params[:overtime_delivery])
          flash[:success] = pat(:update_success, :model => 'Overtime_delivery', :id =>  "#{params[:id]}")
          params[:save_and_continue] ?
            redirect(url(:'delivery/overtime_deliveries', :index)) :
            redirect(url(:'delivery/overtime_deliveries', :edit, :id => @overtime_delivery.id))
        else
          flash.now[:error] = pat(:update_error, :model => 'overtime_delivery')
          render 'delivery/overtime_deliveries/edit'
        end
      else
        flash[:warning] = pat(:update_warning, :model => 'overtime_delivery', :id => "#{params[:id]}")
        halt 404
      end
    end

    delete :destroy, :with => :id do
      @title = "Overtime_deliveries"
      overtime_delivery = OvertimeDelivery.find(params[:id])
      if overtime_delivery
        if overtime_delivery.destroy
          flash[:success] = pat(:delete_success, :model => 'Overtime_delivery', :id => "#{params[:id]}")
        else
          flash[:error] = pat(:delete_error, :model => 'overtime_delivery')
        end
        redirect url(:'delivery/overtime_deliveries', :index)
      else
        flash[:warning] = pat(:delete_warning, :model => 'overtime_delivery', :id => "#{params[:id]}")
        halt 404
      end
    end

    delete :destroy_many do
      @title = "Overtime_deliveries"
      unless params[:overtime_delivery_ids]
        flash[:error] = pat(:destroy_many_error, :model => 'overtime_delivery')
        redirect(url(:'delivery/overtime_deliveries', :index))
      end
      ids = params[:overtime_delivery_ids].split(',').map(&:strip).map(&:to_i)
      overtime_deliveries = OvertimeDelivery.find(ids)

      if OvertimeDelivery.destroy overtime_deliveries

        flash[:success] = pat(:destroy_many_success, :model => 'Overtime_deliveries', :ids => "#{ids.to_sentence}")
      end
      redirect url(:'delivery/overtime_deliveries', :index)
    end
  end

end
