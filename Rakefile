require 'rake'
require 'rake/rdoctask'
require 'rake/gempackagetask'

desc 'Generate documentation for prometheus_conv'
Rake::RDocTask.new(:doc) { |rdoc|
  rdoc.title    = 'prometheus_conv documentation'
  rdoc.rdoc_dir = 'doc'

  rdoc.options        <<
    '--line-numbers'  <<  # Include line numbers in the source code
    '--inline-source' <<  # Show method source code inline, rather
                          # than via a popup link
    '--all'           <<  # Include all methods (not just public)
                          # in the output
    '-c' << 'UTF-8'       # HTML character-set

  rdoc.rdoc_files.include(
    'README', 'COPYING', 'ChangeLog',
    'lib/**/*.rb', 'bin/*'
  )
}

spec = Gem::Specification.new do |s|
  s.name             = 'prometheus_conv'
  s.version          = '0.0.1.' << `svnversion`.chomp[/\d+/]
  s.author           = 'Jens Wille'
  s.email            = 'jens.wille@uni-koeln.de'
  s.summary          = 'Convert prometheus files to various formats'
  s.files            = FileList['lib/**/*.rb', 'bin/*', '[A-Z]*', 'example/*'].to_a
  s.require_path     = 'lib'
  s.bindir           = 'bin'
  s.executables      = %w[prometheus_conv]
  s.has_rdoc         = true
  s.extra_rdoc_files = %w[README COPYING ChangeLog]

  s.rdoc_options    << '--title' << 'prometheus_conv documentation' <<
                       '--main' << 'README'                         <<
                       '--line-numbers'                             <<
                       '--inline-source'                            <<
                       '--all'                                      << 
                       '-c' << 'UTF-8'

  s.add_dependency('xmlstreamin')
  s.add_dependency('ruby-nuggets')
end

desc 'Build gem package for prometheus_conv'
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end

desc 'Upload latest gem to gem server'
task :upload_gem => [:gem] do
  host = 'prometheus.khi.uni-koeln.de'
  user = 'prometheus'
  path = '/var/www/rubygems'

  latest_gem = Dir.glob('pkg/*.gem').sort_by { |gem|
    File.mtime(gem)
  }.last

  sh "scp #{latest_gem} #{user}@#{host}:#{path}/gems"
  sh "ssh #{user}@#{host} 'index_gem_repository.rb -d #{path} -v'"
end
