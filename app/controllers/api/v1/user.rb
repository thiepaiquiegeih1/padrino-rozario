# encoding: utf-8
Rozario::App.controllers :user, map: 'api/v1/user' do
  post :create, :csrf_protection => false do
    require 'json'
    params = JSON.parse(request.body.read)
    udata = params
    udata["role"] = "user"

    udata["discount_code"] = ""
    udata["discount_code"] += udata["discount1"].to_s
    udata["discount_code"] += udata["discount2"].to_s
    udata["discount_code"] += udata["discount3"].to_s

    udata.delete("discount1")
    udata.delete("discount2")
    udata.delete("discount3")
    @user_account = UserAccount.new(udata)
    @user_account.gen_subscribe_code
    if @user_account.save
      ua = UserAccount.authenticate(udata["email"], udata["password"])
      if ua.present?
        session[:user_id] = ua.id
        set_current_account(ua)
        res = { email: ua.email,
              name: ua.surname,
              phone: ua.tel }
      end
    else
      halt 409
      res = "Error"
    end
    content_type :json
    res.to_json
  end

  get :unique do
    email = params['email']
    return false.to_json if UserAccount.where(email: email).first
    return true.to_json
  end
end
