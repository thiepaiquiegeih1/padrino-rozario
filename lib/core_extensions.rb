# encoding: utf-8
# frozen_string_literal: true

# config/initializers/core_extensions.rb

module CoreExtensions
  module NumericClamp
    def clamp(min, max)
      self < min ? min : (self > max ? max : self)
    end
  end
end

unless Numeric.method_defined?(:clamp) # Применяем патч только если метод не существует
  Numeric.class_eval do 
    include CoreExtensions::NumericClamp
  end
  Padrino.logger.debug "Numeric#clamp extension loaded"
else
  Padrino.logger.debug "Native Numeric#clamp method detected"
end

unless Hash.respond_to?(:transform_values) # unless RUBY_VERSION >= '2.4.0' 
  class Hash
    def transform_values
      return enum_for(:transform_values) unless block_given?
      each_with_object({}) { |(k, v), h| h[k] = yield(v) }
    end
  end
  # Теперь работает: `{ a: 1, b: 2 }.transform_values { |v| v * 2 } # => { a: 2, b: 4 }`
end