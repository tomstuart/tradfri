require 'open3'
require 'tempfile'
require 'tradfri/gateway'
require 'tradfri/service'

module Tradfri
  class Client < Struct.new(:coap_client_path)
    METHOD_GET = 'get'
    METHOD_PUT = 'put'

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
        args =
          '-k', key,
          '-m', METHOD_GET,
          '-o', file.path,
          uri.to_s

        Open3.capture3(coap_client_path, *args)

        file.read
      end
    end

    def put(key, uri, payload)
      args =
        '-k', key,
        '-m', METHOD_PUT,
        '-e', payload,
        uri.to_s

      Open3.capture3(coap_client_path, *args)
    end
  end
end
