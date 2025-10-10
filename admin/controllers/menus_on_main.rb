# encoding: utf-8
Rozario::Admin.controllers :menus_on_main do
  get :index do
    redirect url(:'menus_on_main/leftmenus', :index)
  end

  Rozario::Admin.controllers :'menus_on_main/leftmenus' do
    get :index do
      @title = "Leftmenus"
      @leftmenus = Leftmenu.all
      render 'menus_on_main/leftmenus/index'
    end

    get :new do
      @title = pat(:new_title, :model => 'leftmenu')
      @leftmenu = Leftmenu.new
      render 'menus_on_main/leftmenus/new'
    end

    post :create do
      @leftmenu = Leftmenu.new(params[:leftmenu])
      if @leftmenu.save
        @title = pat(:create_title, :model => "leftmenu #{@leftmenu.id}")
        flash[:success] = pat(:create_success, :model => 'Leftmenu')
        params[:save_and_continue] ? redirect(url(:'menus_on_main/leftmenus', :index)) : redirect(url(:'menus_on_main/leftmenus', :edit, :id => @leftmenu.id))
      else
        @title = pat(:create_title, :model => 'leftmenu')
        flash.now[:error] = pat(:create_error, :model => 'leftmenu')
        render 'menus_on_main/leftmenus/new'
      end
    end

    get :edit, :with => :id do
      @title = pat(:edit_title, :model => "leftmenu #{params[:id]}")
      @leftmenu = Leftmenu.find(params[:id])

      #categories_by_lm_ids = LeftmenuCats.where(category_id: @leftmenu.category_ids).pluck(:category_id)
      #tmp_ids = categories_by_lm_ids + @leftmenu.category_ids
      #@lmcat_collection = Category.where(id: tmp_ids.uniq)

      @tst = LeftmenuCats.where(leftmenu_id: @leftmenu.id)

      if @leftmenu
        render 'menus_on_main/leftmenus/edit'
      else
        flash[:warning] = pat(:create_error, :model => 'leftmenu', :id => "#{params[:id]}")
        halt 404
      end
    end

    put :update, :with => :id do
      @title = pat(:update_title, :model => "leftmenu #{params[:id]}")
      @leftmenu = Leftmenu.find(params[:id])

      if @leftmenu.update_attributes(params[:leftmenu]) or @leftmenu 

        params[:leftmenu_cats].each do |index, c|
          catsub = LeftmenuCats.where(leftmenu_id: @leftmenu.id, category_id: c[:category_id])
          if !catsub.empty?
            catsub.update_all(c)
          end
        end

        flash[:success] = pat(:update_success, :model => 'leftmenu', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:'menus_on_main/leftmenus', :index)) :
          redirect(url(:'menus_on_main/leftmenus', :edit, :id => @leftmenu.id))

      else
        flash[:warning] = pat(:update_warning, :model => 'leftmenu', :id => "#{params[:id]}")
        halt 404
      end

    end

    delete :destroy, :with => :id do
      @title = "Leftmenus"
      leftmenu = Leftmenu.find(params[:id])
      if leftmenu
        if leftmenu.destroy
          flash[:success] = pat(:delete_success, :model => 'Leftmenu', :id => "#{params[:id]}")
        else
          flash[:error] = pat(:delete_error, :model => 'leftmenu')
        end
        redirect url(:'menus_on_main/leftmenus', :index)
      else
        flash[:warning] = pat(:delete_warning, :model => 'leftmenu', :id => "#{params[:id]}")
        halt 404
      end
    end

    delete :destroy_many do
      @title = "Leftmenus"
      unless params[:leftmenu_ids]
        flash[:error] = pat(:destroy_many_error, :model => 'leftmenu')
        redirect(url(:'menus_on_main/leftmenus', :index))
      end
      ids = params[:leftmenu_ids].split(',').map(&:strip).map(&:to_i)
      leftmenus = Leftmenu.find(ids)

      if Leftmenu.destroy leftmenus

        flash[:success] = pat(:destroy_many_success, :model => 'Leftmenus', :ids => "#{ids.to_sentence}")
      end
      redirect url(:'menus_on_main/leftmenus', :index)
    end
  end


end
