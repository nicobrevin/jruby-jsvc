class JSVC::Initd

  def self.define_params(&block)
    dsl = ParamDSL.new
    dsl.instance_eval(&block)
    @parameters = (@parameters || []) + dsl.parameters
  end

  def self.defined_param_names
    @parameters.map {|p| p.name }
  end

  def self.defined_params
    @parameters && Hash[*@parameters.map {|p| [p.name, p] }.flatten]
  end

  def self.clear_defined!
    @parameters = nil
  end

  class ParamDSL

    def initialize
      @parameters = []
    end

    def doc(string)
      @next_doc = string
    end

    def string(name, &defaults)
      define(:string, name, &defaults)
    end

    def path(name, &defaults)
      define(:path, name, &defaults)
    end

    def boolean(name, &defaults)
      define(:boolean, name, &defaults)
    end

    def define(type, name, &defaults)
      doc = @next_doc
      @next_doc = nil
      @parameters << Parameter.new(type, name, doc, &defaults)
    end

    def parameters
      @parameters.clone
    end

    private

    def get_default_java_property(prop_name)
      fail_unless_jruby_present!
      command = "jruby -e 'puts Java::JavaLang::System.get_property(\"#{prop_name}\")'"
      `#{command}`
    end

    def fail_unless_jruby_present!
      `which jruby`
      raise "jruby interpreter needed and not installed or not in PATH" if $? != 0
    end

  end

  class Parameter

    attr_reader :type
    attr_reader :name
    attr_reader :doc

    def initialize(type, name, doc, &defaults)
      @type = type
      @name = name
      @doc = doc
      @defaults_proc = defaults
    end

    def default(context)

      return nil if @defaults_proc.nil?

      result = @defaults_proc.call(context)

      if result.is_a?(Hash)
        result[context.mode]
      else
        result
      end
    end
  end

  class ParamError < StandardError

    attr_reader :param_name

    def initialize(name)
      @param_name = name
      super(@param_name)
    end
  end

  # Raised when a value is looked for a parameter that isn't defined and
  # no value could be found for it either
  class UnknownParamError < ParamError ; end

  # Raised when a value is looked for for which no value has been given and
  # default has been specified
  class MissingParamError < ParamError ; end


  class Context

    attr_reader :mode

    def initialize(mode, parameters, values)
      @mode = mode
      @parameters = parameters
      @values = values
    end

    def method_missing(m, *args, &block)
      key = m
      if @values.has_key?(key)
        @values[key]
      else
        p = @parameters[key]
        raise UnknownParamError.new(key) if p.nil?

        if (v = p.default(self)).nil?
          raise MissingParamError.new(key)
        else
          v
        end
      end
    end

    def get_binding
      binding
    end
  end
end
