
#
# Command line interface for generating init.d scripts for controlling
# jruby-jsvc daemons
#
class JSVC::InitdCLI

  require 'jsvc/initd_cli/params'

  def initialize
  end

  def run(argv)
    params, *extra = Params.new.parse(argv)

    options = {
      :template_dir => find_template_dir
    }

    if extra.include? "--help"
      print_template_parameter_help(options, params)
    else
      mode = :dev
      build_from_template(options, mode, params)
    end
  end

  private

  def print_template_parameter_help(options, params)
    puts "Usage: jruby-jsvc-initd [OPTIONS] --param-[PARAM_NAME]=PARAM_VALUE"
    puts
    puts "Known parameters:
"
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
  def build_from_template(options, mode, params)
    begin
      JSVC::Initd.new(options).write($stdout, mode, params)
    rescue JSVC::Initd::UnknownParamError => e
      msg =
        "Template tried to reference parameter '#{e.param_name}', but this was " +
        "not supplied via --param-PARAM-NAME"

      $stderr.puts msg
      exit 1
    rescue JSVC::Initd::MissingParamError => e
      msg = "You must supply a value for #{e.param_name}"

      $stderr.puts msg
      exit 1
    end
  end

  def parse(argv)

  end

  def find_template_dir
    ['/usr/share/jruby-jsvc/templates', 'templates/linux'].
      find {|dirname| File.directory?(dirname) }
  end

end

