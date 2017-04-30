require 'tradfri/gateway'
require 'tradfri/service'

module Tradfri
  def self.discover_gateways
    Service.discover.map do |service|
      Gateway.new(service.host, service.port)
    end
  end
end
