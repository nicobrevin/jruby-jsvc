require 'jsvc'
require 'jsvc/initd'

module InitdHelper
  def write_script(fname, mode, template_options)
    File.open(fname, 'w') do |f|
      JSVC::Initd.new.write(f, mode, template_options)
    end
  end
end
