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

  it 'runs in dev mode, loading templates from the working directory' do
    `bin/jruby-jsvc-initd --param-script-name=Web --param-module-name=Server --param-app-path=./lib`
  end

  it 'barfs if you do not pass all the required parameters in' do
  end

  it 'can take non-standard parameters from the command line in the form "--param-[NAME]=[VALUE]"' do

  end

  it 'can run in debian mode, loading templates from /usr/share/jruby-jsvc/templates' do
    # fakeroot, perhaps?
  end

end
