$:.unshift('lib')
require 'athena'

begin
  require 'hen'

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
rescue LoadError
  abort "Please install the 'hen' gem first."
end
