require 'tempfile'
require 'uri'

require 'tradfri/device'

module Tradfri
  class Gateway < Struct.new(:host, :port, :key)
    CLIENT_PATH = 'bin/coap-client'

    SCHEME = 'coaps'
    DISCOVERY_PATH = '/.well-known/core'
    METHOD_GET = 'get'

    def bulbs
      Tempfile.open do |file|
        args =
          CLIENT_PATH,
          '-k', key,
          '-m', METHOD_GET,
          '-o', file.path,
          discovery_uri.to_s

        system *args

        file.read.split(',').
          map { |link| %r{\A</(?<uri>/\d+/\d+)>}.match(link) }.
          compact.
          map { |match| discovery_uri.merge(match[:uri]) }.
          map { |uri| Device.new(uri) }.
          select(&:bulb?)
      end
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
