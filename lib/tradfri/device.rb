module Tradfri
  class Device < Struct.new(:gateway, :uri)
    # https://github.com/IPSO-Alliance/pub/blob/master/reg/xml/3311.xml
    ON_OFF = 5850
    OFF = 0
    ON = 1

    BULBS = 15001 # TODO discover this

    def bulb?
      %r{\A/#{BULBS}/\d+\z}.match?(uri.path)
    end

    def on
      gateway.send_command uri, ON_OFF => ON
    end

    def off
      gateway.send_command uri, ON_OFF => OFF
    end
  end
end
