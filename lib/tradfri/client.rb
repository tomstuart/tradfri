require 'json'
require 'tempfile'
require 'tradfri/gateway'
require 'tradfri/service'

module Tradfri
  class Client < Struct.new(:coap_client_path)
    METHOD_GET = 'get'
    METHOD_PUT = 'put'

    # https://github.com/IPSO-Alliance/pub/blob/master/reg/xml/3311.xml
    LIGHT_CONTROL = 3311

    def discover_gateways(keys)
      Service.discover.map do |service|
        connect_to service.host, service.port, keys[service.mac_address]
      end
    end

    def connect_to(host, port, key)
      Gateway.new(self, host, port, key)
    end

    def get(key, uri)
      Tempfile.open do |file|
        args = coap_client_path,
          '-k', key,
          '-m', METHOD_GET,
          '-o', file.path,
          uri.to_s

        system *args

        file.read
      end
    end

    def put(key, uri, state)
      args = coap_client_path,
        '-k', key,
        '-m', METHOD_PUT,
        '-e', JSON.generate(LIGHT_CONTROL => [state]),
        uri.to_s

      puts args.join(' ')
      system *args
    end
  end
end
