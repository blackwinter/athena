#--
###############################################################################
#                                                                             #
# athena -- Convert database files to various formats                         #
#                                                                             #
# Copyright (C) 2007-2011 University of Cologne,                              #
#                         Albertus-Magnus-Platz,                              #
#                         50923 Cologne, Germany                              #
#                                                                             #
# Authors:                                                                    #
#     Jens Wille <jens.wille@uni-koeln.de>                                    #
#                                                                             #
# athena is free software; you can redistribute it and/or modify it under the #
# terms of the GNU Affero General Public License as published by the Free     #
# Software Foundation; either version 3 of the License, or (at your option)   #
# any later version.                                                          #
#                                                                             #
# athena is distributed in the hope that it will be useful, but WITHOUT ANY   #
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS   #
# FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for     #
# more details.                                                               #
#                                                                             #
# You should have received a copy of the GNU Affero General Public License    #
# along with athena. If not, see <http://www.gnu.org/licenses/>.              #
#                                                                             #
###############################################################################
#++

require 'athena/version'

# See README.

module Athena

  autoload :Parser,  'athena/parser'
  autoload :Record,  'athena/record'
  autoload :Formats, 'athena/formats'

  extend self

  PLUGIN_FILENAME = 'athena_plugin.rb'

  def load_env_plugins
    load_plugin_files($LOAD_PATH.map { |path|
      file = File.expand_path(PLUGIN_FILENAME, path)
      file if File.file?(file)
    }.compact)
  end

  def load_gem_plugins
    load_plugin_files(Gem::Specification.map { |spec|
      spec.matches_for_glob(PLUGIN_FILENAME)
    }.flatten)
  end

  def parser(config, format)
    Parser.new(config, format)
  end

  def input_formats
    Formats.formats[:in].sort
  end

  def output_formats
    Formats.formats[:out].sort
  end

  def valid_format?(direction, format)
    Formats.valid_format?(direction, format)
  end

  def valid_input_format?(format)
    valid_format?(:in, format)
  end

  def valid_output_format?(format)
    valid_format?(:out, format)
  end

  def deferred_output?(format)
    Formats[:out, format].deferred?
  end

  def raw_output?(format)
    Formats[:out, format].raw?
  end

  def with_format(format, *args, &block)
    Formats[:out, format].wrap(*args, &block)
  end

  private

  def load_plugin_files(plugins)
    plugins.each { |plugin|
      begin
        load plugin
      rescue Exception => err
        warn "Error loading Athena plugin: #{plugin}: #{err} (#{err.class})"
      end
    }
  end

end

Athena.load_env_plugins
Athena.load_gem_plugins if defined?(Gem)
