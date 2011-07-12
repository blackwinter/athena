# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{athena}
  s.version = "0.1.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Jens Wille}]
  s.date = %q{2011-07-12}
  s.description = %q{Convert database files to various formats.}
  s.email = %q{jens.wille@uni-koeln.de}
  s.executables = [%q{athena}]
  s.extra_rdoc_files = [%q{README}, %q{COPYING}, %q{ChangeLog}]
  s.files = [%q{lib/athena/util.rb}, %q{lib/athena/record.rb}, %q{lib/athena/formats/xml.rb}, %q{lib/athena/formats/lingo.rb}, %q{lib/athena/formats/ferret.rb}, %q{lib/athena/formats/dbm.rb}, %q{lib/athena/formats/sql.rb}, %q{lib/athena/formats/sisis.rb}, %q{lib/athena/version.rb}, %q{lib/athena/parser.rb}, %q{lib/athena/formats.rb}, %q{lib/athena.rb}, %q{bin/athena}, %q{README}, %q{ChangeLog}, %q{Rakefile}, %q{COPYING}, %q{example/dump-my.sql}, %q{example/config.yaml}, %q{example/dump-pg.sql}, %q{example/example.xml}, %q{example/sisis-ex.txt}]
  s.homepage = %q{http://prometheus.rubyforge.org/athena}
  s.rdoc_options = [%q{--charset}, %q{UTF-8}, %q{--title}, %q{athena Application documentation (v0.1.5)}, %q{--main}, %q{README}, %q{--line-numbers}, %q{--all}]
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{prometheus}
  s.rubygems_version = %q{1.8.5}
  s.summary = %q{Convert database files to various formats.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<builder>, [">= 0"])
      s.add_runtime_dependency(%q<xmlstreamin>, [">= 0"])
      s.add_runtime_dependency(%q<ruby-nuggets>, [">= 0.6.4"])
    else
      s.add_dependency(%q<builder>, [">= 0"])
      s.add_dependency(%q<xmlstreamin>, [">= 0"])
      s.add_dependency(%q<ruby-nuggets>, [">= 0.6.4"])
    end
  else
    s.add_dependency(%q<builder>, [">= 0"])
    s.add_dependency(%q<xmlstreamin>, [">= 0"])
    s.add_dependency(%q<ruby-nuggets>, [">= 0.6.4"])
  end
end
