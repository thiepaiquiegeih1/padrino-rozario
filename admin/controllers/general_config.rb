# encoding: utf-8
Rozario::Admin.controllers :general_config do

  get :index do
    @title = "GeneralConfig"
    #@general_config = GeneralConfig.all
    @general_config = GeneralConfig.order('id desc').paginate(:page => params[:page], :per_page => 20)
    render 'general_config/index'
  end

  get :new do
    @title = pat(:new_title, :model => 'general_config')
    @general_config = GeneralConfig.new
    render 'general_config/new'
  end

  post :create do
    @general_config = GeneralConfig.new(params[:general_config])
    if @general_config.save
      @title = pat(:create_title, :model => "general_config #{@general_config.id}")
      flash[:success] = pat(:create_success, :model => 'GeneralConfig')
      params[:save_and_continue] ? redirect(url(:general_config, :index)) : redirect(url(:general_config, :edit, :id => @general_config.id))
    else
      @title = pat(:create_title, :model => 'general_config')
      flash.now[:error] = pat(:create_error, :model => 'general_config')
      render 'general_config/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "general_config #{params[:id]}")
    @general_config = GeneralConfig.find(params[:id])
    if @general_config
      render 'general_config/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'general_config', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "general_config #{params[:id]}")
    @general_config = GeneralConfig.find(params[:id])
    if @general_config
      if @general_config.update_attributes(params[:general_config])
        flash[:success] = pat(:update_success, :model => 'GeneralConfig', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:general_config, :index)) :
          redirect(url(:general_config, :edit, :id => @general_config.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'general_config')
        render 'general_config/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'general_config', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "GeneralConfig"
    general_config = GeneralConfig.find(params[:id])
    if general_config
      if general_config.destroy
        flash[:success] = pat(:delete_success, :model => 'GeneralConfig', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'general_config')
      end
      redirect url(:general_config, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'general_config', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "GeneralConfig"
    unless params[:general_config_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'general_config')
      redirect(url(:general_config, :index))
    end
    ids = params[:general_config_ids].split(',').map(&:strip).map(&:to_i)
    general_config = GeneralConfig.find(ids)

    if GeneralConfig.destroy general_config
      flash[:success] = pat(:destroy_many_success, :model => 'GeneralConfig', :ids => "#{ids.to_sentence}")
    end
    redirect url(:general_config, :index)
  end
end
