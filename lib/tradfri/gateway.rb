require 'tradfri/device'
require 'uri'

module Tradfri
  class Gateway < Struct.new(:client, :host, :port, :key)
    SCHEME = 'coaps'
    DISCOVERY_PATH = '/.well-known/core'

    def bulbs
      client.get(key, discovery_uri).split(',').
        map { |link| %r{\A</(?<uri>[^>]+)>}.match(link) }.
        compact.
        map { |match| discovery_uri.merge(match[:uri]) }.
        map { |uri| Device.new(self, uri) }.
        select(&:bulb?)
    end

    def put(uri, payload)
      client.put key, uri, payload
    end

    private def discovery_uri
      URI::Generic.build \
        scheme: SCHEME,
        host: host,
        port: port,
        path: DISCOVERY_PATH
    end
  end
end
