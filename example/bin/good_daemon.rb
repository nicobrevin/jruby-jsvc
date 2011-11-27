$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib')))
require 'crazy_daemon'

JRUBY_JSVC_FAIL = false
Crazy::Daemon.init

