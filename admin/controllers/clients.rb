# encoding: utf-8
Rozario::Admin.controllers :clients do

  get :index do
    @title = "Clients"
    @clients = UserAccount.order('id desc').paginate(:page => params[:page], :per_page => 100)
    render 'clients/index'
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "UserAccount #{params[:id]}")
    @client = UserAccount.find(params[:id])
    if @client
      render 'clients/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'UserAccount', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "UserAccount #{params[:id]}")
    @client = UserAccount.find(params[:id])
    if @client
      if @client.update_attributes(params[:user_account])
        flash[:success] = pat(:update_success, :model => 'UserAccount', :id => "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:clients, :index)) :
          redirect(url(:clients, :edit, :id => @client.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'UserAccount')
        render 'clients/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'UserAccount', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Clients"
    client = UserAccount.find(params[:id])
    if client
      if client.destroy
        flash[:success] = pat(:delete_success, :model => 'UserAccount', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'UserAccount')
      end
      redirect url(:clients, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'UserAccount', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Clients"
    unless params[:client_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'UserAccount')
      redirect(url(:clients, :index))
    end
    ids = params[:client_ids].split(',').map(&:strip).map(&:to_i)
    clients = UserAccount.find(ids)
    if UserAccount.destroy clients
      flash[:success] = pat(:destroy_many_success, :model => 'UserAccount', :ids => "#{ids.to_sentence}")
    end
    redirect url(:clients, :index)
  end

  get :export_emails do
    clients = UserAccount.where(:subscribe => true)
    str = ""
    clients.each do |client|
      str += client.email + "|" + "http://rozarioflowers.ru/user_accounts/unsubscribe?email=#{client.email}&code=#{client.subscribe_code}" + "\r\n"
    end
    import_clients = ImportUser.where(:subscribe => true)
    import_clients.each do |client|
      str += client.email + "|" + "http://rozarioflowers.ru/user_accounts/iunsubscribe?email=#{client.email}&code=#{client.subscribe_code}" + "\r\n"
    end
    response.headers['content_type'] = "application/octet-stream"
    attachment("rozario_emails.txt")
    response.write(str)
  end

end
