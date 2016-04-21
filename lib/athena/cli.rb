#--
###############################################################################
#                                                                             #
# A component of athena, the database file converter.                         #
#                                                                             #
# Copyright (C) 2007-2012 University of Cologne,                              #
#                         Albertus-Magnus-Platz,                              #
#                         50923 Cologne, Germany                              #
#                                                                             #
# Copyright (C) 2013-2014 Jens Wille                                          #
#                                                                             #
# Authors:                                                                    #
#     Jens Wille <jens.wille@gmail.com>                                       #
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

require 'cyclops'
require 'athena'

module Athena

  class CLI < Cyclops

    class << self

      def defaults
        super.merge(
          config: 'config.yaml',
          input:  '-',
          output: '-',
          target: nil
        )
      end

    end

    def run(arguments)
      spec = options[:spec] || options[:spec_fallback]
      abort "No input format (spec) specified and none could be inferred." unless spec
      abort "Invalid input format (spec): #{spec}. Use `-L' to get a list of available specs." unless Athena.valid_input_format?(spec)

      format = options[:format] || options[:format_fallback]
      abort "No output format specified and none could be inferred." unless format
      abort "Invalid output format: #{format}. Use `-l' to get a list of available formats." unless Athena.valid_output_format?(format)

      if t = options[:target]
        target_config = config[target = t.to_sym]
      else
        [options[:target_fallback] || 'generic', ".#{spec}", ":#{format}"].inject([]) { |s, t|
          s << (s.last ? s.last + t : t)
        }.reverse.find { |t| target_config = config[target = t.to_sym] }
      end or abort "Config not found for target: #{target}."

      input = options[:input]
      input = arguments.shift unless input != defaults[:input] || arguments.empty?
      input = File.directory?(input) ? Dir.open(input) : open_file_or_std(input)

      quit unless arguments.empty?

      Athena.run(target_config, spec, format, input, open_file_or_std(options[:output], true))
    end

    private

    def merge_config(args = [defaults])
      super
    end

    def opts(opts)
      opts.option(:input__FILE, 'Input file [Default: STDIN]') { |input|
        parts = File.basename(input).split('.')
        options[:spec_fallback]   = parts.last.downcase
        options[:target_fallback] = parts.size > 1 ? parts[0..-2].join('.') : parts.first
      }

      opts.option(:spec__SPEC,
                  'Input format (spec) [Default: file extension of <input-file>]',
                  &:downcase!)

      opts.option(:list_specs, :L,
                  'List available input formats (specs) and exit') {
        print_formats(:in)
      }

      opts.separator

      opts.option(:output__FILE, 'Output file [Default: STDOUT]') { |output|
        options[:format_fallback] = output.split('.').last.downcase
      }

      opts.option(:format__FORMAT,
                  'Output format [Default: file extension of <output-file>]',
                  &:downcase!)

      opts.option(:list_formats, 'List available output formats and exit') {
        print_formats(:out)
      }

      opts.separator

      opts.option(:target__ID,
                  "Target whose config to use [Default: <input-file> minus file extension,",
                  "plus '.<spec>', plus ':<format>' (reversely in turn)]")
    end

    def print_formats(direction)
      puts "Available #{direction}put formats:"

      Athena.send("#{direction}put_formats").each { |name, klass|
        line, format = "  - #{name}", klass.format
        line << " (= #{format})" if name != format && Athena.valid_format?(direction, format)

        puts line
      }

      exit
    end

  end

end
