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
      [].tap do |uris|
        Tempfile.open('tradfri') do |file|
          args =
            CLIENT_PATH,
            '-k', key,
            '-m', METHOD_GET,
            '-o', file.path,
            discovery_uri.to_s

          system *args

          file.read.split(',').each do |link|
            match = %r{\A</(?<uri>/#{BULBS}/\d+)>}.match(link)
            uris << URI.join(discovery_uri, match[:uri]) if match
          end
        end
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
