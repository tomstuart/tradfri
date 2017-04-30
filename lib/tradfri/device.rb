module Tradfri
  class Device < Struct.new(:uri)
    BULBS = 15001 # TODO discover this

    def bulb?
      %r{\A/#{BULBS}/\d+\z}.match?(uri.path)
    end
  end
end
