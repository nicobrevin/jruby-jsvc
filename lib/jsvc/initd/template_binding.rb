module JSVC

  class Initd::ParamError < StandardError

    attr_reader :param_name

    def initialize(msg, name)
      @param_name = name
      super(@param_name)
    end
  end

  # Raised when a value is looked for a parameter that isn't defined and
  # no value could be found for it either
  class Initd::UnknownParamError < Initd::ParamError ; end

  # Raised when a value is looked for for which no value has been given and
  # default has been specified
  class Initd::MissingParamError < Initd::ParamError ; end

  class Initd::TemplateBinding

    def initialize(context)
      @context = context
    end

    def method_missing(method_name, *args, &block)
      @context.send(method_name)
    end

  end
end
