require 'jsvc'
require 'jsvc/initd/param_dsl'

describe "JSVC::Initd::ParamDSL" do

  before do
    JSVC::Initd.clear_defined!
  end

  def define_params(&block)
    JSVC::Initd.define_params(&block)
  end

  def defined
    JSVC::Initd.defined_params
  end

  def context(mode=:dev)
    JSVC::Initd::Context.new(mode, defined, {})
  end

  describe "defining parameters" do

    it "defined with no docs" do

      define_params do
        string :test
      end

      param = defined[:test]
      param.should_not be_nil
      param.name.should eq(:test)
      param.doc.should be_nil
      param.default(context).should be_nil
    end

    it "defined with a doc string" do
      define_params do
        doc 'this is only a test'
        string :test
      end

      param = defined[:test]
      param.should_not be_nil
      param.name.should eq(:test)
      param.doc.should eq('this is only a test')
      param.default(context).should be_nil
    end

    it "defined with a default" do
      define_params do
        string :test do
          'this is merely a test'
        end
      end

      param = defined[:test]
      param.should_not be_nil
      param.name.should eq(:test)
      param.doc.should be_nil
      param.default(context).should eq('this is merely a test')
    end

    it "defined with mode-switched defaults" do
      define_params do
        string :test do
          {:dev => 'this is merely a test', :prod => 'this is no longer a test'}
        end
      end

      param = defined[:test]
      param.should_not be_nil
      param.name.should eq(:test)
      param.doc.should be_nil
      param.default(context).should eq('this is merely a test')
      param.default(context(:prod)).should eq('this is no longer a test')
    end

    it "defined with defaults that refer to other parameters" do

      define_params do
        string(:cat)   { "Tabby" }
        string(:pussy) { |d| "Fat #{d.cat}" }
      end

      param = defined[:pussy]
      param.should_not be_nil
      param.name.should eq(:pussy)
      param.doc.should be_nil
      param.default(context).should eq('Fat Tabby')
    end
  end
end
