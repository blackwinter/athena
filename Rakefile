require File.expand_path(%q{../lib/athena/version}, __FILE__)

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
      :author       => %q{Jens Wille},
      :email        => %q{jens.wille@uni-koeln.de},
      :dependencies => %w[builder xmlstreamin ruby-nuggets]
    }
  }}
rescue LoadError => err
  warn "Please install the `hen' gem. (#{err})"
end
