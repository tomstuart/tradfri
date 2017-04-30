require 'tempfile'
require 'uri'

module Tradfri
  class Gateway < Struct.new(:host, :port, :key)
    CLIENT_PATH = 'bin/coap-client'

    SCHEME = 'coaps'
    DISCOVERY_PATH = '/.well-known/core'
    METHOD_GET = 'get'

    BULBS = 15001 # TODO discover this

    def bulb_uris
      Tempfile.open do |file|
        args =
          CLIENT_PATH,
          '-k', key,
          '-m', METHOD_GET,
          '-o', file.path,
          discovery_uri.to_s

        system *args

        file.read.split(',').
          map { |link| %r{\A</(?<uri>/#{BULBS}/\d+)>}.match(link) }.
          compact.
          map { |match| discovery_uri.merge(match[:uri]) }
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
