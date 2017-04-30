require 'dnssd'

module Tradfri
  class Service < Struct.new(:name, :host, :port)
    SERVICE_TYPE = '_coap'
    TRANSPORT_PROTOCOL = '_udp'
    INTERNET_PROTOCOL = DNSSD::Service::IPv4
    REGISTRATION_TYPE = [SERVICE_TYPE, TRANSPORT_PROTOCOL].join('.')

    def self.discover
      browse(REGISTRATION_TYPE).map do |reply|
        host, port = resolve(reply, INTERNET_PROTOCOL)
        Service.new(reply.name, host, port)
      end
    end

    private_class_method def self.browse(registration_type)
      [].tap do |replies|
        DNSSD.browse! registration_type do |reply|
          replies << reply if reply.flags.add?
          break unless reply.flags.more_coming?
        end
      end
    end

    private_class_method def self.resolve(browse_reply, protocol)
      DNSSD.resolve! browse_reply do |resolve_reply|
        DNSSD::Service.getaddrinfo(resolve_reply.target, protocol).each do |address_reply|
          return [address_reply.address, resolve_reply.port]
        end

        break unless resolve_reply.flags.more_coming?
      end

      raise "couldn’t resolve #{browse_reply.name}"
    end
  end
end
