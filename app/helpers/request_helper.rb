# encoding: utf-8

require 'benchmark'

Rozario::App.helpers do
  def load_subdomain
    time = Benchmark.realtime do
      subdomains = @request.subdomains
      subdomains.shift if subdomains.first =~ /www/
      #if PADRINO_ENV == 'development'
        # subdomains.shift if subdomains.first =~ /(staging)/
      #end
      subdomain_name = subdomains.shift
      @subdomain = Subdomain.where(:url => subdomain_name || 'murmansk').first
      if @subdomain
        @has_geo_subdomain = true
        params_hash = {}
        session[:subdomain] = @subdomain.id
        params_hash[:title] = @subdomain.title
        # params_hash[:keywords] = @subdomain.keywords
        params_hash[:description] = @subdomain.description
        params_hash = wrap_seo_params(params_hash)
        @address = "г. #{@subdomain.city}"
        @title = params_hash[:title].present? ? params_hash[:title] : "Розарио Доставка №1. Букетов и живых цветов"
        @description = params_hash[:description].present? ? params_hash[:description].strip : "Цветочный центр Розарио - доставка цветов #{@subdomain.city if @subdomain}, доставка букетов, оформление праздничных и свадебных букетов, огромный выбор комнатных цветов и рассады."
        # @keywords = params_hash[:keywords].present? ? params_hash[:keywords] : "доставка цветов #{@subdomain.city if @subdomain}  доставка букетов заказ цветов цветы букеты"
      end
    end
  rescue => e
    # gauge("request => #{@request.inspect}")
    gauge("subdomain_name => #{subdomain_name}")
    gauge("@subdomain => #{@subdomain.nil?}")
    gauge("PADRINO_ENV => #{PADRINO_ENV}")
    gauge "load_subdomain took #{time} seconds"
  end

  def has_geo_subdomain?
    @has_geo_subdomain
  end

  def redirect_to_root_domain
    redirect @request.env['REQUEST_URI'].sub(/:\/\/\w+\./, '://'), 301
  end

  def redirect_to_root_domain_if_has_geo_subdomain
    if has_geo_subdomain?
      redirect_to_root_domain
    end
  end

end
