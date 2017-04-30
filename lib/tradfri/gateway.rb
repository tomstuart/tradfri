require 'json'
require 'tempfile'
require 'uri'

require 'tradfri/device'

module Tradfri
  class Gateway < Struct.new(:client, :host, :port, :key)
    SCHEME = 'coaps'
    DISCOVERY_PATH = '/.well-known/core'
    METHOD_GET = 'get'
    METHOD_PUT = 'put'

    # https://github.com/IPSO-Alliance/pub/blob/master/reg/xml/3311.xml
    LIGHT_CONTROL = 3311

    def bulbs
      Tempfile.open do |file|
        args =
          client.coap_client_path,
          '-k', key,
          '-m', METHOD_GET,
          '-o', file.path,
          discovery_uri.to_s

        system *args

        file.read.split(',').
          map { |link| %r{\A</(?<uri>/\d+/\d+)>}.match(link) }.
          compact.
          map { |match| discovery_uri.merge(match[:uri]) }.
          map { |uri| Device.new(self, uri) }.
          select(&:bulb?)
      end
    end

    def send_command(uri, state)
      args = client.coap_client_path,
        '-k', key,
        '-m', METHOD_PUT,
        '-e', JSON.generate(LIGHT_CONTROL => [state]),
        uri.to_s

      puts args.join(' ')
      system *args
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
