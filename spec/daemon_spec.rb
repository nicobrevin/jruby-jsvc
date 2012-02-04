require 'rubygems'
require 'spec/helpers'

describe "Controlling a daemon" do

  include InitdHelper

  let(:script_fname) { '/tmp/test-jsvc' }

  let(:example_app_dir) { File.join(File.dirname(__FILE__), '..', 'example')  }

  before do
    JSVC.init

    write_script(script_fname, :dev, {:app_name => 'example',
        :script_name => 'good_daemon', :module_name => 'Crazy',
        :debug => false,
        :app_home => example_app_dir})

    File.chmod(0755, script_fname)
  end

  def consume_stream(s, &block)
    Thread.new do
      begin
        while true
          begin
            puts 'a'
            line = s.readline
            puts 'b'
            puts line
            result = yield line if block_given?
            break if result
          rescue EOFError
            break
          end
        end
      rescue
        puts "error: #{$!}"
      end
    end
  end

  # pending until I can gather the mental strength to complete it
  it "can start a daemon up, and then stop"
#do
#    start_command = "#{script_fname} start"

 #   IO.popen3(start_command) do |stdin, sout, serr|
  #    begin
#        consume_stream(sout) {|l|
#          if l.strip == 'Waiting for something to happen'
#            true
#          end
#        }.join

   #     sleep 10
#
 #       puts "thread returned, pid: #{pid.inspect}"
 #       `#{script_fname} stop`
  #    end
  #  end
  #end

end

