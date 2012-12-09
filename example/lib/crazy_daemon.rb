#
# I'm defining the daemon here, but you could require it from somewhere
# else, or pull in a ruby gem or anything
#

module Crazy
  module Daemon

    # Initialise your application to the point you are confident that you
    # should be able to do some useful work (get a DB connection, bind to a
    # socket, open config files, etc).  Not actually part of the jruby-jsvc
    # Daemon interface, but it is useful to put this somewhere.
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

    # Detection method for the jruby-jsvc library to determine whether you're
    # daemon is ready to start serving.  If false, jruby-jsvc will not call
    # `start` and your daemon will not start.
    def setup?
      @setup
    end

    # jruby-jsvc is telling you to start doing whatever it is your daemon does,
    # such as serving http requests, sending emails, sorting text files or
    # whatever it is your daemon is supposed to do.
    def start
      while not @stopped
        puts "Waiting for something to happen"
        sleep 1
      end
    end

    # Respond to SIGUSR2.  An opportunity to reload your application, roll log
    # files, or whatever else it is you'd like to do.  Optional.
    def signal
      puts "Reloading my config files, starting again"
    end

    # jruby-jsvc is asking you politely to stop. Finish serving any http
    # requests, don't start any new jobs.  This should cause the main thread of your
    # application, the one that called `start`, to return back to the caller,
    # however this method should exit immediately - don't join the main thread
    # or anything like that.
    def stop
      @stopped = true
    end

    extend self
  end
end
