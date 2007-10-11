require 'lib/athena/version'

FILES = FileList['lib/**/*.rb'].to_a
EXECS = FileList['bin/*'].to_a
RDOCS = %w[README COPYING ChangeLog]
OTHER = FileList['[A-Z]*', 'example/*'].to_a

task(:doc_spec) {{
  :title      => 'athena Application documentation',
  :rdoc_files => RDOCS + FILES
}}

task(:gem_spec) {{
  :name             => 'athena',
  :version          => Athena::VERSION,
  :summary          => 'Convert database files to various formats',
  :files            => FILES + EXECS + OTHER,
  :require_path     => 'lib',
  :bindir           => 'bin',
  :executables      => EXECS,
  :extra_rdoc_files => RDOCS,
  :dependencies     => %w[xmlstreamin ruby-nuggets]
}}
