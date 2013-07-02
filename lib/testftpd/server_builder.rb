require_relative 'server'

module TestFtpd

  class ServerBuilder

    DEFAULT_PORT_RANGE = (21212..21232).to_a

    def self.build(config, ports)
      new.build(config, ports)
    end

    def build(config, ports = DEFAULT_PORT_RANGE)
      @server = nil
      ports.each do |port|
        attempt_to_build config.merge(port: port)
        break if @server
      end
      @server
    end

    private

    def attempt_to_build(options)
      @server = Server.new(options)
    rescue Errno::EADDRINUSE
      nil
    end

  end

end
