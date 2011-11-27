module JSVC

  def self.init
    begin
      require 'erubis'
    rescue LoadError
      require 'rubygems'
      require 'erubis'
    end

    require 'jsvc/initd'
  end
end
