#--
###############################################################################
#                                                                             #
# A component of athena, the database file converter.                         #
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

require 'athena'

module Athena

  module Formats

    CRLF    = %Q{\015\012}
    CRLF_RE = %r{(?:\r?\n)+}

    def self.[](direction, format)
      if direction == :out
        if format.class < Base
          if format.class.direction != direction
            raise DirectionMismatchError,
              "expected #{direction}, got #{format.class.direction}"
          else
            format
          end
        else
          Base.formats[direction][format].new
        end
      else
        Base.formats[direction][format]
      end
    end

    class Base

      @formats = { :in => {}, :out => {} }

      class << self

        def formats
          Base.instance_variable_get(:@formats)
        end

        def valid_format?(direction, format)
          if format.class < Base
            direction == format.class.direction
          else
            formats[direction].has_key?(format)
          end
        end

        private

        def register_format(direction, *aliases, &block)
          format = name.split('::').last.
            gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
            gsub(/([a-z\d])([A-Z])/, '\1_\2').
            downcase

          register_format!(direction, format, *aliases, &block)
        end

        def register_format!(direction, format, *aliases, &block)
          raise "must be a sub-class of #{Base}" unless self < Base

          klass = Class.new(self, &block)

          klass.instance_eval %Q{
            def direction; #{direction.inspect}; end
            def name; '#{format}::#{direction}'; end
            def to_s; '#{format}'; end
          }

          [format, *aliases].each { |name|
            if existing = formats[direction][name]
              raise DuplicateFormatDefinitionError,
                "format already defined (#{direction}): #{name}"
            else
              formats[direction][name] = klass
            end
          }
        end

      end

      def parse(*args)
        raise NotImplementedError, 'must be defined by sub-class'
      end

      def convert(record)
        raise NotImplementedError, 'must be defined by sub-class'
      end

      def wrap
        yield self
      end

      def deferred?
        false
      end

      def raw?
        false
      end

    end

    class FormatError < StandardError; end

    class DuplicateFormatDefinitionError < FormatError; end
    class DirectionMismatchError         < FormatError; end

    ConfigError = Parser::ConfigError

    class NoRecordElementError      < ConfigError; end
    class IllegalRecordElementError < ConfigError; end

  end

end

Dir[__FILE__.sub(/\.rb\z/, '/**/*.rb')].sort.each { |rb|
  require "athena/formats/#{File.basename(rb, '.rb')}"
}
