require 'tradfri/gateway'
require 'tradfri/service'

module Tradfri
  class Client < Struct.new(:coap_client_path)
    def discover_gateways(keys)
      Service.discover.map do |service|
        connect_to service.host, service.port, keys[service.mac_address]
      end
    end

    def connect_to(host, port, key)
      Gateway.new(self, host, port, key)
    end
  end
end
