# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{athena}
  s.version = "0.1.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jens Wille"]
  s.date = %q{2011-04-29}
  s.description = %q{Convert database files to various formats.}
  s.email = %q{jens.wille@uni-koeln.de}
  s.executables = ["athena"]
  s.extra_rdoc_files = ["README", "COPYING", "ChangeLog"]
  s.files = ["lib/athena/util.rb", "lib/athena/record.rb", "lib/athena/formats/xml.rb", "lib/athena/formats/lingo.rb", "lib/athena/formats/ferret.rb", "lib/athena/formats/dbm.rb", "lib/athena/formats/sisis.rb", "lib/athena/version.rb", "lib/athena/parser.rb", "lib/athena/formats.rb", "lib/athena.rb", "bin/athena", "README", "ChangeLog", "Rakefile", "COPYING", "example/config.yaml", "example/example.xml", "example/sisis-ex.txt"]
  s.homepage = %q{http://prometheus.rubyforge.org/athena}
  s.rdoc_options = ["--line-numbers", "--main", "README", "--charset", "UTF-8", "--all", "--title", "athena Application documentation (v0.1.4)"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{prometheus}
  s.rubygems_version = %q{1.7.2}
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
