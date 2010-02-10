require %q{lib/athena/version}

begin
  require 'hen'

  Hen.lay! {{
    :rubyforge => {
      :project => %q{prometheus},
      :package => %q{athena}
    },

    :gem => {
      :version      => Athena::VERSION,
      :summary      => %q{Convert database files to various formats.},
      :files        => FileList['lib/**/*.rb', 'bin/*'].to_a,
      :extra_files  => FileList['[A-Z]*', 'example/*'].to_a,
      :dependencies => %w[builder xmlstreamin ruby-nuggets]
    }
  }}
rescue LoadError
  abort "Please install the 'hen' gem first."
end
