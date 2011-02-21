require 'jsvc'

module Crazy
  module InitD
    def create(out, options)
      configuration = JSVC::Configuration.new
      configuration.write(out, options)
    end

    extend self
  end
end
