# encoding: utf-8
Rozario::App.controllers :auth, map: 'api/v1/auth' do
  get :curr_user do
    if session[:user_id].present?
      user = UserAccount.find(session[:user_id])
      content_type :json
      res = { email: user.email,
              name: user.surname,
              phone: user.tel }
      res.to_json
    else
      halt 403, 'Not Authorized'
    end
  end

  post :login, csrf_protection: false do
    params = JSON.parse(request.body.read)
    user_account = UserAccount.authenticate(params["email"], params["password"])
    if user_account.present?
      session[:user_id] = user_account.id
      set_current_account(user_account)
      res = { email: user_account.email,
              name: user_account.surname,
              phone: user_account.tel }
    else
      res = "Error"
      halt 403
    end
    content_type :json
    res.to_json
  end

end
