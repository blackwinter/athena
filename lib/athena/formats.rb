#--
###############################################################################
#                                                                             #
# A component of athena, the database file converter.                         #
#                                                                             #
# Copyright (C) 2007-2012 University of Cologne,                              #
#                         Albertus-Magnus-Platz,                              #
#                         50923 Cologne, Germany                              #
#                                                                             #
# Copyright (C) 2013 Jens Wille                                               #
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

require 'athena'

module Athena

  # In order to support additional input and/or output formats,
  # Athena::Formats::Base needs to be sub-classed and an instance
  # method _parse_ or an instance method _convert_ supplied,
  # respectively. This way, a specific format can even function
  # as both input and output format.
  #
  # == Defining custom formats
  #
  # Define one or more classes that inherit from Athena::Formats::Base
  # and either call Athena::Formats.register with your format class as
  # parameter or call Athena::Formats.register_all with your surrounding
  # namespace (which will then recursively add any format definitions below
  # it). Alternatively, you can call Athena::Formats::Base.register_format
  # <b>at the end</b> of your class definition to register just this class.
  #
  # The directions supported by your custom format are determined
  # automatically; see below for further details.
  #
  # === Defining an _input_ format
  #
  # An input format must provide a *public* instance method _parse_ that
  # accepts an input object (usually an IO object) and a block it passes
  # each record (Athena::Record) to. See Athena::Formats::Base#parse.
  #
  # === Defining an _output_ format
  #
  # An output format must provide a *public* instance method _convert_ that
  # accepts a record (Athena::Record) and either returns a suitable value for
  # output or writes the output itself. See Athena::Formats::Base#convert.
  #
  # == Aliases
  #
  # In order to provide an alias name for a format, simply assign
  # the format class to a new constant. Then you need to call
  # <tt>Athena::Formats.register(your_new_const)</tt> to register
  # your alias.

  module Formats

    # CR+LF line ending.
    CRLF = %Q{\015\012}

    # Regular expression to match (multiple) CR+LF line endings.
    CRLF_RE = %r{(?:\r?\n)+}

    # Mapping of format direction to method required for implementation.
    METHODS = { :in => 'parse', :out => 'convert' }

    @formats = { :in => {}, :out => {} }

    class << self

      # Container for registered formats per direction. Use ::find or ::[]
      # to access them.
      attr_reader :formats

      # call-seq:
      #   Athena::Formats[direction, format, *args] -> aFormat
      #
      # Retrieves the format for +direction+ by its name +format+ (see
      # ::find) and initializes it with +args+ (see Base#init). Returns
      # +format+ unaltered if it already is a format instance, while
      # making sure that it supports +direction+.
      def [](direction, format, *args)
        res = find(direction, format, true)
        res.is_a?(Base) ? res : res.init(direction, *args)
      end

      # call-seq:
      #   Athena::Formats.find(direction, format) -> aFormatClass
      #
      # Retrieves the format for +direction+ by its name +format+. Returns
      # +format+'s class if it already is a format instance, while making
      # sure that it supports +direction+.
      def find(direction, format, instance = false)
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
              if klass.has_direction?(direction)
                return instance ? format : klass
              else
                raise DirectionMismatchError.new(direction, directions)
              end
            else
              raise ArgumentError, "invalid format of type #{klass}" <<
                " (expected one of: Symbol, String, or sub-class of #{Base})"
            end
        end
      end

      # call-seq:
      #   Athena::Formats.valid_format?(direction, format) -> true | false
      #
      # Indicates whether the +direction+/+format+ combination is supported,
      # i.e. a format by name +format+ has been registered and supports
      # +direction+.
      def valid_format?(direction, format)
        if format.class < Base
          format.class.has_direction?(direction)
        else
          formats[direction].key?(format.to_s)
        end
      end

      # call-seq:
      #   Athena::Formats.register(klass, name = nil, relax = false) -> anArray | nil
      #
      # Registers +klass+ as format under +name+ (defaults to Base.format).
      # Only warns instead of raising any errors when +relax+ is +true+.
      # Returns an array of the actual name +klass+ has been registered
      # under and the directions supported; returns +nil+ if nothing has
      # been registered.
      def register(klass, name = nil, relax = false)
        unless klass < Base
          return if relax
          raise ArgumentError, "must be a sub-class of #{Base}"
        end

        name = name ? name.to_s : klass.format
        methods = klass.public_instance_methods(false).map { |m| m.to_s }
        directions = klass.directions

        METHODS.each { |direction, method|
          next unless methods.include?(method)

          if formats[direction].key?(name)
            err = DuplicateFormatDefinitionError.new(direction, name)
            raise err unless relax

            warn err
            next
          else
            directions << direction unless klass.has_direction?(direction)
            formats[direction][name] = klass
          end
        }

        [name, directions] unless directions.empty?
      end

      # call-seq:
      #   Athena::Formats.register_all(klass = self) -> anArray
      #
      # Recursively registers all formats *below* +klass+ (see ::register).
      # Returns an array of all registered format names with their supported
      # directions.
      def register_all(klass = self, registered = [])
        names  = klass.constants
        names -= klass.superclass.constants if klass.is_a?(Class)

        names.each { |name|
          const = klass.const_get(name)
          next unless const.is_a?(Module)

          registered << register(const, format_name("#{klass}::#{name}"), true)
          register_all(const, registered)
        }

        registered.compact
      end

      # call-seq:
      #   Athena::Formats.format_name(name) -> aString
      #
      # Formats +name+ as suitable format name.
      def format_name(fn)
        fn.sub(/\A#{self}::/, '').
          gsub(/([a-z\d])(?=[A-Z])/, '\1_').
          gsub(/::/, '/').downcase
      end

    end

    # Base class for all format classes. See Athena::Formats
    # for more information.

    class Base

      class << self

        # call-seq:
        #   Athena::Formats::Base.format -> aString
        #
        # Returns this class's format name.
        def format
          @format ||= Formats.format_name(name)
        end

        # call-seq:
        #   Athena::Formats::Base.directions -> anArray
        #
        # Returns an array of the directions supported by this class.
        def directions
          @directions ||= []
        end

        # call-seq:
        #   Athena::Formats::Base.has_direction?(direction) -> true | false
        #
        # Indicates whether this class supports +direction+.
        def has_direction?(direction)
          directions.include?(direction)
        end

        # call-seq:
        #   Athena::Formats::Base.init(direction, *args) -> aFormat
        #
        # Returns a new instance of this class for +direction+ initialized
        # with +args+ (see #init).
        def init(direction, *args)
          new.init(direction, *args)
        end

        protected

        # call-seq:
        #   Athena::Formats::Base.register_format(name = nil, relax = false) -> anArray | nil
        #
        # Shortcut for <tt>Athena::Formats.register(self, name, relax)</tt>.
        # Must be called at the end of or after the class definition (in order
        # to determine the supported direction(s), the relevant instance
        # methods must be available).
        def register_format(name = nil, relax = false)
          Formats.register(self, name, relax)
        end

      end

      # The _input_ format's configuration hash.
      attr_reader :config

      # The _input_ format's "record element" (interpreted
      # differently by each format).
      attr_reader :record_element

      # The _output_ format's output target.
      attr_reader :output

      # call-seq:
      #   format.init(direction, *args) -> format
      #
      # Initializes _format_ for +direction+ with +args+ (see #init_in and
      # #init_out), while making sure that +direction+ is actually supported
      # by _format_. Returns _format_.
      def init(direction, *args)
        if self.class.has_direction?(direction)
          send("init_#{direction}", *args)
        else
          raise DirectionMismatchError.new(direction, self.class.directions)
        end

        self
      end

      # call-seq:
      #   format.parse(input) { |record| ... } -> anInteger
      #
      # Parses +input+ according to the format represented by this class
      # and passes each record to the block. _Should_ return the number of
      # records parsed.
      #
      # NOTE: Must be implemented by the sub-class in order to function as
      # _input_ format.
      def parse(input)
        raise NotImplementedError, 'must be defined by sub-class'
      end

      # call-seq:
      #   format.convert(record) -> aString | anArray | void
      #
      # Converts +record+ (Athena::Record) according to the format represented
      # by this class. The return value may be different for each class; it is
      # irrelevant when #raw? has been defined as +true+.
      #
      # NOTE: Must be implemented by the sub-class in order to function as
      # _output_ format.
      def convert(record)
        raise NotImplementedError, 'must be defined by sub-class'
      end

      # call-seq:
      #   format.raw? -> true | false
      #
      # Indicates whether output is written directly in #convert.
      def raw?
        false
      end

      # call-seq:
      #   format.deferred? -> true | false
      #
      # Indicates whether output is to be deferred and only be written after
      # all records have been converted (see #run).
      def deferred?
        false
      end

      # call-seq:
      #   format.run(spec, input) -> anInteger
      #
      # Runs the _output_ generation for _input_ format +spec+ (Athena::Formats::Base)
      # on +input+. Outputs a sorted and unique list of records when #deferred?
      # is +true+. Returns the return value of #parse.
      def run(spec, input)
        parsed, block = nil, if raw?
          lambda { |record| record.to(self) }
        elsif deferred?
          deferred = []
          lambda { |record| deferred << record.to(self) }
        else
          lambda { |record| output.puts(record.to(self)) }
        end

        wrap { parsed = spec.parse(input, &block) }

        if deferred?
          deferred.flatten!; deferred.sort!; deferred.uniq!
          output.puts(deferred)
        end

        parsed
      end

      private

      # call-seq:
      #   format.init_in(config)
      #
      # Initialize _input_ format (with +config+).
      def init_in(config)
        @config = config

        case @record_element = @config.delete(:__record_element)
          when *@__record_element_ok__ || String
            # fine!
          when nil
            raise NoRecordElementError, 'no record element specified'
          else
            raise IllegalRecordElementError, "illegal record element #{@record_element.inspect}"
        end
      end

      # call-seq:
      #   format.init_out(output = nil)
      #
      # Initialize _output_ format (with optional +output+).
      def init_out(output = nil)
        @output = output
      end

      # call-seq:
      #   format.wrap { ... }
      #
      # Hook for wrapping the output generation in #run.
      def wrap
        yield
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

    class ConfigError < StandardError; end

    class NoRecordElementError      < ConfigError; end
    class IllegalRecordElementError < ConfigError; end

  end

end

Dir[__FILE__.sub(/\.rb\z/, '/**/*.rb')].sort.each { |rb|
  require "athena/formats/#{File.basename(rb, '.rb')}"
}

Athena::Formats.register_all
