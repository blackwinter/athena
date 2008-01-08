begin
  require 'hen'
rescue LoadError
  abort "Please install the 'hen' gem first."
end

require 'lib/athena/version'

Hen.lay! {{
  :rubyforge => {
    :package => 'athena'
  },

  :gem => {
    :version      => Athena::VERSION,
    :summary      => 'Convert database files to various formats.',
    :files        => FileList['lib/**/*.rb', 'bin/*'].to_a,
    :extra_files  => FileList['[A-Z]*', 'example/*'].to_a,
    :dependencies     => %w[xmlstreamin ruby-nuggets]
  }
}}
