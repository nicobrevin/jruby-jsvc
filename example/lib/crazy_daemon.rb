#
# I'm defining the daemon here, but you could require it from somewhere
# else, or pull in a ruby gem or anything
#

module Crazy
  module Daemon

    def init
      puts "Pretending to setup stuff I need, and bind to sockets, etc"
      if JRUBY_JSVC_FAIL
        # if you can't initialize your environment and you know why,
        # you can fail and give an error message using the DaemonInitError.
        raise JSVC::DaemonInitError, "My database hurts, please mend it."
      else
        @setup = true
      end
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

    def reload
      puts "Reloading my config files, starting again"
    end

    def stop
      @stopped = true
    end

    extend self
  end
end
