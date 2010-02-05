# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{athena}
  s.version = "0.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jens Wille"]
  s.date = %q{2010-02-05}
  s.default_executable = %q{athena}
  s.description = %q{Convert database files to various formats.}
  s.email = %q{jens.wille@uni-koeln.de}
  s.executables = ["athena"]
  s.extra_rdoc_files = ["COPYING", "ChangeLog", "README"]
  s.files = ["lib/athena/util.rb", "lib/athena/record.rb", "lib/athena/formats/xml.rb", "lib/athena/formats/lingo.rb", "lib/athena/formats/ferret.rb", "lib/athena/formats/dbm.rb", "lib/athena/formats/sisis.rb", "lib/athena/version.rb", "lib/athena/parser.rb", "lib/athena/formats.rb", "lib/athena.rb", "bin/athena", "README", "ChangeLog", "Rakefile", "COPYING", "example/config.yaml", "example/example.xml", "example/sisis-ex.txt"]
  s.homepage = %q{http://prometheus.rubyforge.org/athena}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--main", "README", "--charset", "UTF-8", "--title", "athena Application documentation", "--all"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{prometheus}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Convert database files to various formats.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<builder>, [">= 0"])
      s.add_runtime_dependency(%q<xmlstreamin>, [">= 0"])
      s.add_runtime_dependency(%q<ruby-nuggets>, [">= 0"])
    else
      s.add_dependency(%q<builder>, [">= 0"])
      s.add_dependency(%q<xmlstreamin>, [">= 0"])
      s.add_dependency(%q<ruby-nuggets>, [">= 0"])
    end
  else
    s.add_dependency(%q<builder>, [">= 0"])
    s.add_dependency(%q<xmlstreamin>, [">= 0"])
    s.add_dependency(%q<ruby-nuggets>, [">= 0"])
  end
end
