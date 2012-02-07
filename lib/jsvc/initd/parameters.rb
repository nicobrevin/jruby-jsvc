JSVC::Initd.declare_defaults :debian
JSVC::Initd.declare_defaults :dev

JSVC::Initd.define_params do

  doc "Name of your application"
  string :app_name

  doc "Name of the ruby constant under which the Daemon module can be found"
  string :module_name

  doc "Name of the ruby script that is called to start the application"
  string :script_name do |d|
    d.app_name
  end

  doc "Home location of the application.  Some defaults are based from this location"
  path :app_home do |d|
    {
      :dev    => File.expand_path(Dir.pwd),
      :debian => "/usr/lib/#{d.app_name}"
    }
  end

  doc "Path to the JRuby installation"
  path :jruby_home do |d|
    {
      :dev    => get_default_java_property("jruby.home"),
      :debian => "/usr/lib/jruby"
    }
  end

  doc "Path to the jsvc binary"
  path :jsvc do |d|
    {
      :dev    => `which jsvc`,
      :debian => "/usr/bin/jsvc"
    }
  end

  doc "Java home directory"
  path :java_home do |d|
    {
      :dev    => get_default_java_property("java.home"),
      :debian => "/usr/lib/jvm/default-java"
    }
  end

  doc "Path to script which starts the application"
  path :script_path do |d|
    File.join(d.app_home, 'bin', d.script_name + '.rb')
  end

  doc "Path to jruby-jsvc.jar"
  path :jruby_jsvc_jar do |d|
    {
      :debian => '/usr/share/java/jruby-jsvc.jar',
      :dev    => Dir.exists?('target') && File.expand_path(Dir['target/jruby-jsvc*.jar'].sort.last)
    }
  end

  doc "Path to commons-daemon.jar"
  path :commons_daemon_jar do |d|
    '/usr/share/java/commons-daemon.jar'
  end

  doc "Unix user that the daemon process will eventually run as"
  string :app_user do |d|
    {
      :debian => d.app_name,
      :dev    => ENV['USER']
    }
  end

  doc "Path to pidfile location"
  path :pidfile do |d|
    {
      :debian => "/var/run/#{d.app_name}/#{d.script_name}.pid",
      :dev => File.expand_path(d.script_name + '.pid')
    }
  end

  doc "Options supplied to ARGV of your program"
  string :program_options do |d|
    ""
  end

  doc "Run the daemon in debug mode"
  boolean :debug do |d|
    {
      :debian => false,
      :dev    => true
    }
  end

  doc "Not sure..."
  boolean :logging_enabled do
    true
  end

end
