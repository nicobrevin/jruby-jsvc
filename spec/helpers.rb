require 'jsvc'
require 'jsvc/initd'

RSpec::Matchers.define :exit_with do |expected, _|
  match do |actual|
    actual[:status].exitstatus == expected
  end

  failure_message_for_should do |actual|
    "expected that `#{actual[:command]}` would have exited with: #{expected}\nexited with: #{actual[:status].exitstatus}\nstderr:\n#{actual[:stderr]}\nstdout:\n#{actual[:stdout]}"
  end

end

require 'popen4'

module ExecHelper

  def run(cmd)
    @last_command = cmd

    @last_status = POpen4.popen4(@last_command) do |stdout, stderr, stdin, pid|
      @last_stdout = stdout.read.strip
      @last_stderr = stderr.read.strip
      @last_pid = pid
    end
  end

  def last_run
    {
      :command => @last_command,
      :stdout  => @last_stdout,
      :stderr  => @last_stderr,
      :pid     => @last_pid,
      :status  => @last_status
    }
  end

  def exec(cmd)
    run cmd
    if @last_status.exitstatus != 0
      raise "command: #{cmd} failed with #{@last_status.exitstatus}\n#{@all_output}"
    end
    true
  end

  def all_output
    @last_stdout + "\n" + @last_stderr
  end

  attr_reader :last_stdout, :last_stderr, :last_status
end

module InitdHelper
  def write_script(fname, mode, template_options)
    File.open(fname, 'w') do |f|
      JSVC::Initd.new.write(f, mode, template_options)
    end
  end
end
