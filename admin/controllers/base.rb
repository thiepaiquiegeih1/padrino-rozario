# encoding: utf-8
Rozario::Admin.controllers :base do
  get :index, :map => "/" do
    render "base/index"
  end
end
