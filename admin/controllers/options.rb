# encoding: utf-8
Rozario::Admin.controllers :options do

  get :index do
    @title = "Options"
    dir = File.join(Padrino.root, "public", "uploads", "options")
    @curr_file = File.basename(Dir[dir + "/*"].take(1)[0])
    render 'options/index'
  end

  put :upload_image do
    if params[:file]
      userdir = File.join(Padrino.root, "public", "uploads", "options")
      filename = File.join(userdir, params[:file][:filename].to_s)
      datafile = params[:file]
      FileUtils.rm_rf("#{userdir}/.", secure: true)
      fh = File.open(filename, "w+b") do |file|
        file.write(datafile[:tempfile].read)
      end
      if fh
        flash[:notice] = "Файл загружен"
      else
        flash[:error] = "Ошибка загрузки файла"
      end
      redirect back
    end
  end

  #get :edit, :with => :id do
    #render 'products/edit'
  #end

  #put :update, :with => :id do
    #flash[:warning] = pat(:update_warning, :model => 'product', :id => "#{params[:id]}")
    #halt 404
  #end

end