#
# I'm defining the daemon here, but you could require it from somewhere
# else, or pull in a ruby gem or anything
#

module Crazy
  module Daemon

    def init
      puts "Pretending to setup stuff I need, and bind to sockets, etc"
      @setup = true
    end

    def setup?
      @setup
    end

    def start
      while not @stopped
        puts "Waiting for something to happen"
        sleep 1
      end
    end

    def stop
      @stopped = true
    end

    extend self
  end
end
