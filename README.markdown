## jruby-jsvc

Run your jruby application as a unix daemon, via
[jsvc](http://commons.apache.org/daemon/).  Works around the fact that you
can't really `fork` from jruby/java.

With jruby-jsvc you can check your application has started properly before it
is backgrounded, and then control it like you would other unix daemons.  If
you have commons-daemon-1.0.6 you can make use of SIGUSR2 to have some custom
signal handling in your daemon (roll your logs, reload your configuration).

## How to create a jruby-jsvc daemon

These instructions are aimed at someone using a debian based system, although
you can use jruby-jsvc with any *nix that can run jsvc, you just need to delve
a bit deeper.

There is a working example that can be installed as a debian package.  It is very
simple, but should give you a complete guide to how to deploy apps on to debian
with jruby-jsvc.

1. Install jsvc.  Your system may come with it, or you may have to build it
yourself from http://commons.apache.org/daemon/.  It isn't the most difficult
thing to get running. By default, jruby-jsvc expects the `jsvc` excecutable
to be on your path, and expects the `commons-daemon` jar to be installed in to
`/usr/share/java/commons-daemon.jar`.

1. Install jsvc-jruby.  You can either check it out from source and build it,
or install the debian packages from the downloads page.

1. Take a look at `example/lib/crazy_daemon.rb` - you need to create an object
called `Daemon` underneath your application's namespace, something like
`Crazy::Daemon`.  This should respond to `setup?`, `start` and `stop` methods.
See comments in that file for details on the interface.

1. Create a start-up script - the entry point in to your application.  This
should load your daemon module and initialize your application so
that it is ready to start serving once `Daemon.start` is called.  There are a
couple of examples in example/bin - one which succeeds, the other fails
(Demonstrating the DaemonInitException).

1. Create an init.d script using the jruby-jsvc-initd command.  Take a look at
bin/make-debian-initd-files.sh for an example.  The jruby-jsvc-initd command has
some help output to aid you.

1. Start/stop the daemon with your init.d script.  Crazy.
