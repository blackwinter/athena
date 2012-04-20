# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "athena"
  s.version = "0.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jens Wille"]
  s.date = "2012-04-20"
  s.description = "Convert database files to various formats."
  s.email = "jens.wille@uni-koeln.de"
  s.executables = ["athena"]
  s.extra_rdoc_files = ["README", "COPYING", "ChangeLog"]
  s.files = ["lib/athena/version.rb", "lib/athena/formats.rb", "lib/athena/formats/lingo.rb", "lib/athena/formats/dbm.rb", "lib/athena/formats/sql.rb", "lib/athena/formats/xml.rb", "lib/athena/formats/sisis.rb", "lib/athena/formats/ferret.rb", "lib/athena/cli.rb", "lib/athena/record.rb", "lib/athena.rb", "bin/athena", "ChangeLog", "COPYING", "README", "Rakefile", "example/dump-my.sql", "example/sisis-ex.txt", "example/dump-pg.sql", "example/config.yaml", "example/example.xml", "example/athena_plugin.rb"]
  s.homepage = "http://prometheus.rubyforge.org/athena"
  s.rdoc_options = ["--charset", "UTF-8", "--title", "athena Application documentation (v0.2.2)", "--main", "README", "--line-numbers", "--all"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "prometheus"
  s.rubygems_version = "1.8.23"
  s.summary = "Convert database files to various formats."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<builder>, [">= 0"])
      s.add_runtime_dependency(%q<xmlstreamin>, [">= 0"])
      s.add_runtime_dependency(%q<ruby-nuggets>, [">= 0.8.1"])
    else
      s.add_dependency(%q<builder>, [">= 0"])
      s.add_dependency(%q<xmlstreamin>, [">= 0"])
      s.add_dependency(%q<ruby-nuggets>, [">= 0.8.1"])
    end
  else
    s.add_dependency(%q<builder>, [">= 0"])
    s.add_dependency(%q<xmlstreamin>, [">= 0"])
    s.add_dependency(%q<ruby-nuggets>, [">= 0.8.1"])
  end
end
