require 'spec/helpers'
require 'jsvc/initd_cli'

describe 'building an init.d style daemon controller script' do

  describe 'JSVC::InitdCLI::Params' do

    def parse(args)
      JSVC::InitdCLI::Params.new.parse(args)
    end

    it 'returns an empty hash and no extras when you pass it an empty array' do
      parse([]).should == [{}]
    end

    it 'converts parameters in the form "--param-[KEY]=[VALUE]" to key value pairs' do
      parse(['--param-cat=dog']).should == [{:cat => 'dog'}]
      parse(['--param-cat=dog', '--param-cheese=edam']).should ==
        [{:cat => 'dog', :cheese => 'edam'}]
    end

    it 'converts hyphens in to underscores' do
      parse(['--param-top-hat=none']).should == [{:top_hat => 'none'}]
    end

    it 'leaves underscores in parameter names alone' do
      parse(['--param-shoe_laces=long']).should == [{:shoe_laces => 'long'}]
    end

    it 'returns any non-matching parameters' do
      parse(['log', '--param-jvm=sun', '--verbose', '--param-cmd=nil', 'bob']).should ==
        [{:jvm => 'sun', :cmd => 'nil'}, 'log', '--verbose', 'bob']
    end
  end

  describe "output" do

    include ExecHelper

    def create_script(args)
      run("ruby -Ilib bin/jruby-jsvc-initd #{args}")
    end

    it "can create a script to run the daemon in debug mode" do
      create_script "dev --param-app-name=test --param-module-name=MyModule"

      last_run.should exit_with(0)

      last_stdout.should_not include("-outfile")
      last_stdout.should_not include("-errfile")

      last_stdout.should include("-nodetach")
      last_stdout.should include("-debug")
    end

    it "can be created in debian mode" do
      create_script "debian --param-app-name=test --param-module-name=MyModule"

      last_run.should exit_with(0)

      last_stdout.should include("-outfile")
      last_stdout.should include("-errfile")

      last_stdout.should_not include("-nodetach")
      last_stdout.should_not include("-debug")

      # FIXME some more assertions would be nice
    end


    it "fails with a nice error message if you miss a required arg" do
      create_script "dev --param-app-name --param-module-name=MyModule --param-debug=true"

      last_run.should exit_with(1)
      last_stderr.should include("You must supply a value for app_name via --param-PARAM-NAME=VALUE")
      last_stderr.should include("See the help for more details")
    end

    it "can be created without a mode" do
      all_args = JSVC::Initd.defined_params.map {|n, p| "--param-#{p.name}=false" }.
        join(" ")

      create_script " #{all_args}"

      last_run.should exit_with(0)
    end
  end

  # IDEA: use vagrant to do more realistic testing?

  it 'runs in dev mode, loading templates from the working directory'
  it 'barfs if you do not pass all the required parameters in'
  it 'can take non-standard parameters from the command line in the form "--param-[NAME]=[VALUE]"'
  it 'can run in debian mode, loading templates from /usr/share/jruby-jsvc/templates'

end
