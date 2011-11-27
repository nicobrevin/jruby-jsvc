module JSVC

  def self.init
    require 'java'
    begin
      require 'erubis'
    rescue LoadError
      require 'rubygems'
      require 'erubis'
    end

    require 'jsvc/initd'
  end
end
