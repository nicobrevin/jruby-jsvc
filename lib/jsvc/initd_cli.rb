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
    params, *extra = parse(argv)

    options = {
      :template_dir => find_template_dir
    }

    if extra.include? "--help"
      print_template_parameter_help(options, params)
    else
      build_from_template(options, params)
    end
  end

  private

  def print_template_parameter_help(options, params)
    to_format = JSVC::Initd.defined_param_names.map do |name|
      param = JSVC::Initd.defined_params[name]

      [param.name.to_s, param.doc]
    end

    max_widths = to_format.transpose.map {|col| col.map {|v| v.length}.max }

    to_format.each do |row|
      puts row.zip(max_widths).map {|v, w| v.ljust(w) }.join(" ")
    end
  end

  # and output it on stdout
  def build_from_template(options, params)
    begin
      JSVC::Initd.new(options).write($stdout, params)
    rescue JSVC::Initd::MissingParamError => e
      $stderr.puts "You must supply a value for #{e.missing_param}"
      exit 1
    end
  end

  def parse(argv)
    Params.new.parse(argv)
  end

  def find_template_dir
    ['/usr/share/jruby-jsvc/templates', 'templates/linux'].
      find {|dirname| File.directory?(dirname) }
  end

end

