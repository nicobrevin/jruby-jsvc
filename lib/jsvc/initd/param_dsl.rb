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
        raise "no such parameter: #{key}" if p.nil?
        p && p.default(self)
      end
    end

  end
end
