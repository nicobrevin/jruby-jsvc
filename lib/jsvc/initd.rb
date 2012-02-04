class JSVC::Initd
  require 'jsvc/initd/template_binding'
  require 'jsvc/initd/param_dsl'
  require 'jsvc/initd/parameters'

  def initialize(options={})
    @template_dir = options.fetch(:template_dir, default_template_dir)
  end

  def default_template_dir
    File.join(Dir.pwd, 'templates/linux')
  end

  attr_reader :template_dir

  def template_string

    raise "template dir: #{template_dir} does not exist or not a directory" unless
      File.directory?(template_dir)

    template_files = Dir[File.join(template_dir, '*')].
      sort

    raise "no template parts in directory #{template_dir}" if
      template_files.empty?

    template_files.
      map {|fn|File.open(fn, 'r') {|f| f.read } }.
      inject {|a,b| a+b }
  end

  def write(out, mode, template_params)
    template = Erubis::Eruby.new(template_string)
    binding = Context.new(mode, JSVC::Initd.defined_params, template_params).get_binding

    result = template.result(binding)
    out.write(result)
  end
end
