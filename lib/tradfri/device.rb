require 'json'

module Tradfri
  class Device < Struct.new(:gateway, :uri)
    # https://github.com/IPSO-Alliance/pub/blob/master/reg/xml/3311.xml
    LIGHT_CONTROL = 3311
    ON_OFF = 5850
    OFF = 0
    ON = 1
    DIMMER = 5851
    DIMMER_MIN = 0
    DIMMER_MAX = 255
    COLOUR = 5706
    COLOUR_COLD = 'f5faf6'
    COLOUR_NORMAL = 'f1e0b5'
    COLOUR_WARM = 'efd275'

    # I don’t know if/where these are officially documented
    NAME = 9001

    BULBS = 15001 # TODO discover this

    def bulb?
      info.has_key? LIGHT_CONTROL.to_s
    end

    def name
      info[NAME.to_s]
    end

    def info
      data = gateway.get(uri)

      result =
        begin
          JSON.parse(data)
        rescue JSON::ParserError
          {}
        end

      case result
      when Hash
        result
      else
        {}
      end
    end

    def on
      change ON_OFF => ON
    end

    def off
      change ON_OFF => OFF
    end

    def dim(brightness)
      change DIMMER => DIMMER_MIN + (brightness * (DIMMER_MAX - DIMMER_MIN)).round
    end

    def cold
      change COLOUR => COLOUR_COLD
    end

    def normal
      change COLOUR => COLOUR_NORMAL
    end

    def warm
      change COLOUR => COLOUR_WARM
    end

    private def change(state)
      gateway.put uri, LIGHT_CONTROL => [state]
    end
  end
end
