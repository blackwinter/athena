# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "athena"
  s.version = "0.2.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jens Wille"]
  s.date = "2013-07-15"
  s.description = "Convert database files to various formats."
  s.email = "jens.wille@gmail.com"
  s.executables = ["athena"]
  s.extra_rdoc_files = ["README", "COPYING", "ChangeLog"]
  s.files = ["lib/athena.rb", "lib/athena/cli.rb", "lib/athena/formats.rb", "lib/athena/formats/dbm.rb", "lib/athena/formats/ferret.rb", "lib/athena/formats/lingo.rb", "lib/athena/formats/sisis.rb", "lib/athena/formats/sql.rb", "lib/athena/formats/xml.rb", "lib/athena/record.rb", "lib/athena/version.rb", "bin/athena", "COPYING", "ChangeLog", "README", "Rakefile", "example/athena_plugin.rb", "example/config.yaml", "example/dump-my.sql", "example/dump-pg.sql", "example/example.xml", "example/midos-ex.dbm", "example/sisis-ex.txt"]
  s.homepage = "http://github.com/blackwinter/athena"
  s.licenses = ["AGPL"]
  s.rdoc_options = ["--charset", "UTF-8", "--line-numbers", "--all", "--title", "athena Application documentation (v0.2.5)", "--main", "README"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.5"
  s.summary = "Convert database files to various formats."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<builder>, [">= 0"])
      s.add_runtime_dependency(%q<highline>, [">= 0"])
      s.add_runtime_dependency(%q<xmlstreamin>, [">= 0"])
      s.add_runtime_dependency(%q<ruby-nuggets>, [">= 0.9.2"])
    else
      s.add_dependency(%q<builder>, [">= 0"])
      s.add_dependency(%q<highline>, [">= 0"])
      s.add_dependency(%q<xmlstreamin>, [">= 0"])
      s.add_dependency(%q<ruby-nuggets>, [">= 0.9.2"])
    end
  else
    s.add_dependency(%q<builder>, [">= 0"])
    s.add_dependency(%q<highline>, [">= 0"])
    s.add_dependency(%q<xmlstreamin>, [">= 0"])
    s.add_dependency(%q<ruby-nuggets>, [">= 0.9.2"])
  end
end
