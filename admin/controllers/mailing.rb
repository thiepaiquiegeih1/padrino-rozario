# encoding: utf-8
Rozario::Admin.controllers :mailing do

  get :index do
    @title = "Mailing"
    render 'mailing/index'
  end
  
  get :import do
    @title = "Импорт из 1С"
    render 'mailing/import'
  end

  post :start do
    p params
    if params[:string][:recipients].blank? || params[:string][:subject].blank? || params[:string][:body].blank?
      flash.now[:error] = "Заполните все поля"
      render 'mailing/index'
    else
      require 'navvy'
      require 'navvy/job/active_record'
      require 'fileutils'
      tempfile = params[:string][:recipients][:tempfile]
      filetxt = File.join(Padrino.root, "tmp", "tmphjas6723.txt")
      FileUtils.cp tempfile.path, filetxt
      subject = params[:string][:subject]
      body = params[:string][:body]
      Navvy::Job.enqueue(Mailing, :send_emails, filetxt, subject, body)
      #Mailing.send_emails(filetxt, subject, body)
      flash.now[:success] = "Отправка добавлена в задания"
      render 'mailing/ok'
    end
  end

  post :import_emails do
    require 'fileutils'
    require 'iconv'
    p params
    if params[:string].blank? || params[:string][:file].blank?
      flash.now[:error] = "Добавьте файл"
      render 'mailing/import'
    else
      begin
        tmp = params[:string][:file][:tempfile]
        file = File.join(Padrino.root, "public", "tmpxlsfile323719.xlsx")
        FileUtils.cp tmp.path, file
        s = Roo::Excelx.new(file)
        s.default_sheet = s.sheets.first
        @count = 0
        s.each do |row|
          if row.count == 3 && /\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/ === row[2]
            p row
            if ImportUser.create_or_find_by_email(row)
              @count += 1
            end
          end
        end
        FileUtils.rm file
        render 'mailing/ok_import'
	  rescue StandardError => e
        logger.error "This is a test", e
        p ["ERROR", e]
        flash.now[:error] = "Ошибка парсинга файла"
        render 'mailing/import'
      end
    end
  end
end
