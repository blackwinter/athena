require File.expand_path(%q{../lib/athena/version}, __FILE__)

begin
  require 'hen'

  Hen.lay! {{
    :gem => {
      :name         => %q{athena},
      :version      => Athena::VERSION,
      :summary      => %q{Convert database files to various formats.},
      :author       => %q{Jens Wille},
      :email        => %q{jens.wille@gmail.com},
      :license      => %q{AGPL-3.0},
      :homepage     => :blackwinter,
      :dependencies => %w[builder cyclops midos mysql_parser nuggets xmlstreamin]
    }
  }}
rescue LoadError => err
  warn "Please install the `hen' gem. (#{err})"
end
