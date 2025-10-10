# encoding: utf-8

module DscntModule
  def some_method
    return discounts = {
      'severomorsk' => {
        0 => 0, # for all products
        2938 => { '11 rozes' => 0, '15 rozes' => 0 } # for probuct by id (example)
      },
       'pljos' => {
        0 => 350, # for all products
        2938 => { '11 rozes' => 0, '15 rozes' => 0 } # for probuct by id (example)
      }
    }
  end
end