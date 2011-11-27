#
# Command line interface for generating init.d scripts for controlling
# jruby-jsvc daemons
#
class JSVC::InitdCLI

  require 'jsvc/initd_cli/params'

  def initialize
  end

  def run(argv)
    # turns argv in a hash
    params, extra = parse(argv)

    # create the template and output it on stdout
    begin
      JSVC::Initd.new.write($stdout, params)
    rescue JSVC::Initd::MissingParamError => e
      $stderr.puts "You must supply a value for #{e.missing_param}"
      exit 1
    end
  end

  private

  def parse(argv)
    Params.new.parse(argv)
  end

end

