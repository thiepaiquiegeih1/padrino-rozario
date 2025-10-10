# encoding: utf-8
# This method is heavily adapted from the Rails method of determining the subdomain.
require 'rack/request'
require 'domainatrix'

# We re-open the request class to add the subdomains method
module Rack
  class Request
    def subdomains(tld_len=1) # we set tld_len to 1, use 2 for co.uk or similar
      # cache the result so we only compute it once. # кешируем результат, чтобы не выполнять вычисления каждый раз
      @env['rack.env.subdomains'] ||= lambda {
        # check if the current host is an IP address, if so return an empty array # Если хост отсутствует или является IP-адресом, возвращаем пустой массив
        return [] if (host.nil? ||
                      /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/.match(host))
                      host.split('.')[0...(1 - tld_len - 2)] # pull everything except the TLD # Разделяем хост по точке и исключаем TLD. Возвращаем массив субдоменов
      }.call
    end

    def remove_subdomain
      url = Domainatrix.parse(host)
      if @env["SERVER_PORT"].to_i != 80
        url.domain + "." + url.public_suffix + ':' + @env["SERVER_PORT"]
      else
        url.domain + "." + url.public_suffix
      end
    end
  end
end 
