# encoding: utf-8
module RecatpchaInitializer
  def self.registered(app)
    app.use Rack::Recaptcha,
      :private_key => "6LfHoesSAAAAAOrBNEcqu1bhp2yGxn0-sLs60OZd",
      :public_key => "6LfHoesSAAAAAIaCozRMCR9R2olUILtLMyqab3oZ",
      :paths => ""
    app.helpers Rack::Recaptcha::Helpers

  end
end
