$:.unshift('lib')
require 'athena'

begin
  require 'hen'

  Hen.lay! {{
    :rubyforge => {
      :project => %q{prometheus},
      :package => %q{athena}
    },

    :gem => {
      :version      => Athena::VERSION,
      :summary      => 'Convert database files to various formats.',
      :files        => FileList['lib/**/*.rb', 'bin/*'].to_a,
      :extra_files  => FileList['[A-Z]*', 'example/*'].to_a,
      :dependencies     => %w[builder xmlstreamin ruby-nuggets]
    }
  }}
rescue LoadError
  abort "Please install the 'hen' gem first."
end
