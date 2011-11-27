
#
# Parses command line options, turning them in to a key value hash
#
class JSVC::InitdCLI::Params

  #
  # Returns a hash containing parsed options, and other unused options.  Used like so:
  # `options, *unused = parse(ARGV)`
  #
  # Warning: this method blindly converts string input in to symbols
  #
  def parse(args)
    matching, extra = args.
      map {|elem| [elem, pattern.match(elem)] }.
      partition {|elem, match| ! match.nil? }

    options = matching.
      map {|elem, match| [match[1], match[2]]}.
      map {|rawkey, value| [rawkey.gsub('-', '_').intern, value] }.
      inject({}) {|m,(k,v)| m.merge(k => v) }

    [options, *extra.map {|e,m| e} ]
  end

  def pattern
    /^--param-([^=]+)=(.*)$/
  end
end
