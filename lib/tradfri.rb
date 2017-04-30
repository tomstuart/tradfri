require 'tradfri/gateway'
require 'tradfri/service'

module Tradfri
  def self.discover_gateways(keys)
    Service.discover.map do |service|
      Gateway.new(service.host, service.port, keys[service.mac_address])
    end
  end
end
