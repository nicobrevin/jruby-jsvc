require 'erb'
require 'java'

module JSVC
  class Configuration

    def parts
      ["head", "vars", "working", "start-stop", "tail"]
    end

    def default_jruby_home
      @default_jruby_home ||=
        get_default_java_property("jruby.home")
    end

    def default_java_home
      @default_java_home ||=
        get_default_java_property("java.home")
    end

    def jruby_exec
      @jruby_exec ||= `which jruby`
    end

    def get_default_java_property(prop_name)
      `#{jruby_exec} -e 'puts Java::JavaLang::System.get_property("#{prop_name}")'`
    end

  end
end
