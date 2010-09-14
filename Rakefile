require 'date'
require 'rubygems'

desc "creates a rubygem"
task :build => ['clean', 'target/gem/lib/jruby-jsvc.rb'] do
	`mvn install`

	jars = FileList['target/jruby-jsvc-*.jar']
	version = jars.first.gsub(/(?:.+)jruby\-jsvc\-(.+).jar/, '\1').sub(/-SNAPSHOT/, '')

	cp FileList['README.markdown', 'LICENSE'], 'target/gem'
	cp jars, 'target/gem/lib'
	cp File.expand_path('~/.m2/repository/commons-daemon/commons-daemon/1.0.1/commons-daemon-1.0.1.jar'), 'target/gem/lib'

	gemspec = Gem::Specification.new do |s|
		s.name = "jruby-jsvc"
		s.version = version
		s.date = Date.today.to_s
		s.description = "Use jsvc to run a jruby app as an init.d style daemon"
		s.summary = "Use jsvc to run a jruby app as an init.d style daemon"
		s.homepage = 'http://github.com/nicobrevin/jruby-jsvc'
		s.has_rdoc = false

		s.files = FileList['target/gem/**/*']
	end

	Gem::Builder.new(gemspec).build
	mv FileList['*.gem'], 'target'
end

task :clean do
	rm_rf 'target'
end

file 'target/gem/lib/jruby-jsvc.rb' do |t|
	mkdir_p File.dirname(t.name)
	File.open(t.name, 'wb') do |f|
		f.write("Dir.glob('*.jar').each {|jar| require jar}")
	end
end
