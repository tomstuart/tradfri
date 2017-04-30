# `tradfri`, a Ruby interface to IKEA’s smart lighting system

`tradfri` is a Ruby library for talking to the [gateway][] which controls
IKEA’s [TRÅDFRI][] smart lighting system. If you own a TRÅDFRI gateway and some
bulbs, this library lets you turn them on and off from a Ruby program.

The communication with the gateway uses the HTTP-like [CoAP][] protocol over
UDP and is secured with [DTLS][]. I don’t know how the hell any of that works
so this library sends CoAP requests by shelling out to the `coap-client`
program that comes with [`libcoap`][libcoap]. You’ll have to build this
yourself and tell `tradfri` where to find it.

Because the gateway advertises itself with [DNS-SD][], `tradfri` can discover
it automatically without you having to specify an IP address. The CoAP messages
are encrypted, though, so you’ll need the “serial number” (MAC address) and
“security code” (pre-shared key) from the sticker on the underside of the
gateway.

[gateway]: http://www.ikea.com/us/en/catalog/products/00337813/
[TRÅDFRI]: http://www.ikea.com/us/en/catalog/categories/departments/lighting/36812/
[CoAP]: http://coap.technology/
[DTLS]: https://en.wikipedia.org/wiki/Datagram_Transport_Layer_Security
[libcoap]: https://libcoap.net/
[DNS-SD]: https://en.wikipedia.org/wiki/Zero-configuration_networking#DNS-SD

## Building `libcoap`

You should build the `dtls` branch of `libcoap` according to [these
instructions][]. You may need to install other tools like `libtool` and
`automake` for this to work.

Here’s what worked for me:

```bash
$ git clone --recursive --branch dtls https://github.com/obgm/libcoap.git
$ cd libcoap
$ ./autogen.sh
$ ./configure --disable-documentation --disable-shared
$ make
```

[these instructions]: https://libcoap.net/doc/install.html

## Example

Once you’ve built `libcoap`’s `coap-client` binary, you can use `tradfri` like
this:

```ruby
require 'tradfri'

CLIENT_PATH = 'libcoap/examples/coap-client' # wherever you compiled it

SERIAL_NUMBER = 'a0-b1-c2-d3-e4-f5' # from the sticker on your gateway
SECURITY_CODE = 'aBcDeFgHiJkLmNoP' # from the sticker on your gateway
SECRETS = { SERIAL_NUMBER => SECURITY_CODE }

client = Tradfri::Client.new(CLIENT_PATH)
gateways = client.discover_gateways(SECRETS)
gateway = gateways.first
bulbs = gateway.bulbs

puts "Found: #{bulbs.map(&:name).join(', ')}"

bulbs.each do |bulb|
  bulb.on # bulb.off works too
end

loop do
  bulbs.each do |bulb|
    bulb.dim(rand) # 0 is full darkness, 1 is full brightness
    bulb.send(%i{cold normal warm}.sample)
  end

  sleep 5
end
```

## Limitations

This is incredibly hacky and doesn’t work very well, but it’s a start.
