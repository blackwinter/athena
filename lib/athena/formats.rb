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

  # In order to support additional input and/or output formats,
  # Athena::Formats::Base needs to be sub-classed and an instance
  # method _parse_ or an instance method _convert_ supplied,
  # respectively. This way, a specific format can even function
  # as both input and output format.

  module Formats

    CRLF    = %Q{\015\012}
    CRLF_RE = %r{(?:\r?\n)+}

    METHODS = { :in => 'parse', :out => 'convert' }

    @formats = { :in => {}, :out => {} }

    class << self

      attr_reader :formats

      def [](direction, format, *args)
        find(direction, format).init(direction, *args)
      end

      def find(direction, format)
        directions = formats.keys

        unless directions.include?(direction)
          raise ArgumentError, "invalid direction: #{direction.inspect}" <<
            " (must be one of: #{directions.map { |d| d.inspect }.join(', ')})"
        end

        case format
          when Symbol
            find(direction, format.to_s)
          when String
            formats[direction][format] or
              raise FormatNotFoundError.new(direction, format)
          else
            klass = format.class

            if klass < Base && !(directions = klass.directions).empty?
              return format if klass.direction_supported?(direction)
              raise DirectionMismatchError.new(direction, directions)
            else
              raise ArgumentError, "invalid format of type #{klass}" <<
                " (expected one of: Symbol, String, or sub-class of #{Base})"
            end
        end
      end

      def valid_format?(direction, format)
        if format.class < Base
          format.class.direction_supported?(direction)
        else
          formats[direction].has_key?(format.to_s)
        end
      end

      def register(klass, name = nil, relax = false)
        unless klass < Base
          return if relax
          raise ArgumentError, "must be a sub-class of #{Base}"
        end

        name = name ? name.to_s : klass.format
        methods = klass.public_instance_methods(false).map { |m| m.to_s }

        METHODS.each { |direction, method|
          next unless methods.include?(method)

          if formats[direction].has_key?(name)
            err = DuplicateFormatDefinitionError.new(direction, name)
            raise err unless relax

            warn err
            next
          else
            klass.directions << direction.to_s
            formats[direction][name] = klass
          end
        }
      end

      def register_all(klass = self)
        names  = klass.constants
        names -= klass.superclass.constants if klass.is_a?(Class)

        names.each { |name|
          const = klass.const_get(name)
          next unless const.is_a?(Module)

          register(const, format_name("#{klass}::#{name}"), true)
          register_all(const)
        }
      end

      def format_name(fn)
        fn.sub(/\A#{self}::/, '').
          gsub(/([a-z\d])(?=[A-Z])/, '\1_').
          gsub(/::/, '/').downcase
      end

    end

    class Base

      class << self

        def format
          @format ||= Formats.format_name(name)
        end

        def directions
          @directions ||= []
        end

        def direction_supported?(direction)
          directions.include?(direction.to_s)
        end

        def init(direction, *args)
          new.init(direction, *args)
        end

        def register_format(name = nil, relax = false)
          Formats.register(self, name, relax)
        end

      end

      attr_reader :config, :record_element

      def init(direction, *args)
        if self.class.direction_supported?(direction)
          send("init_#{direction}", *args)
        else
          raise DirectionMismatchError.new(direction, self.class.directions)
        end

        self
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

      private

      def init_in(parser)
        @config = parser.config.dup

        case @record_element = @config.delete(:__record_element)
          when *@__record_element_ok__ || String
            # fine!
          when nil
            raise NoRecordElementError, 'no record element specified'
          else
            raise IllegalRecordElementError, "illegal record element #{@record_element.inspect}"
        end
      end

      def init_out
      end

    end

    class FormatError < StandardError; end

    class DuplicateFormatDefinitionError < FormatError
      def initialize(direction, format)
        @direction, @format = direction, format
      end

      def to_s
        "format already defined (#{@direction.inspect}): #{@format.inspect}"
      end
    end

    class FormatNotFoundError < FormatError
      def initialize(direction, format)
        @direction, @format = direction, format
      end

      def to_s
        "format not found (#{@direction.inspect}): #{@format.inspect}"
      end
    end

    class DirectionMismatchError < FormatError
      def initialize(direction, directions)
        @direction, @directions = direction, directions
      end

      def to_s
        "got #{@direction.inspect}, expected one of " <<
          @directions.map { |d| d.inspect }.join(', ')
      end
    end

    ConfigError = Parser::ConfigError

    class NoRecordElementError      < ConfigError; end
    class IllegalRecordElementError < ConfigError; end

  end

end

Dir[__FILE__.sub(/\.rb\z/, '/**/*.rb')].sort.each { |rb|
  require "athena/formats/#{File.basename(rb, '.rb')}"
}

Athena::Formats.register_all
