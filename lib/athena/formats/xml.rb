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

require 'forwardable'
require 'builder'
require 'xmlstreamin'
require 'nuggets/hash/insert'
require 'athena'

module Athena::Formats

  class XML < Base

    # <http://www.w3.org/TR/2006/REC-xml-20060816/#NT-Name>
    ELEMENT_START_RE    = %r{\A[a-zA-Z_:]}
    NON_ELEMENT_CHAR_RE = %r{[^\w:.-]}

    VALUE_SEPARATOR = '|'

    attr_reader :specs

    def parse(source, &block)
      REXML::Document.parse_stream(source, listener(&block))
    end

    def convert(record)
      builder.row {
        builder.id record.id

        record.struct.each { |field, struct|
          if block_given?
            yield field, struct
          else
            builder.tag!(field) {
              struct[:elements].each { |element|
                (struct[:values][element] || []).each { |value|
                  value = (value || '').strip
                  builder.tag!(element, value) unless value.empty?
                }
              }
            }
          end
        }
      }
    end

    class Flat < XML

      def convert(record)
        super { |field, struct|
          strings = []

          struct[:elements].each { |element|
            values = (struct[:values][element] || []).map { |v|
              (v || '').strip
            }.reject { |v| v.empty? }

            strings << (values.empty? ? struct[:empty] : values.join(VALUE_SEPARATOR))
          }

          builder.tag!(field, struct[:string] % strings)
        }
      end

    end

    def wrap(out = nil)
      res = nil
      builder(:target => out).database { res = super() }
      res
    end

    def raw?
      true
    end

    private

    def init_in(*)
      @__record_element_ok__ = [String, Array]
      super

      case @skip_hierarchy = @config.delete(:__skip_hierarchy)
        when Integer
          # fine!
        when nil
          @skip_hierarchy = 0
        else
          raise ConfigError, "illegal value #{@skip_hierarchy.inspect} for skip hierarchy"
      end

      @specs = {}

      @config.each { |element, element_spec| element_spec.each { |field, c|
        element.split('/').reverse.inject({}) { |hash, part|
          s = define_spec(element, field, c, hash.empty? ? :default : hash)
          merge_specs(hash, part, s)
        }.each { |key, s|
          merge_specs(@specs, key, s)
        }
      } }
    end

    def builder(options = {})
      @builder ||= begin
        builder = Builder::XmlMarkup.new({ :indent => 2 }.merge(options))
        builder.instruct!

        def builder.method_missing(sym, *args, &block)
          elem = sym.to_s

          elem.insert(0, '_') unless elem =~ ELEMENT_START_RE
          elem.gsub!(NON_ELEMENT_CHAR_RE, '_')

          super(elem, *args, &block)
        end

        builder
      end
    end

    def listener(&block)
      record_spec = RecordSpec.new(&block)
      record_spec.specs!(specs)

      root_spec   = BaseSpec.new
      [*record_element].each { |re| root_spec.specs!(re => record_spec) }

      spec        = BaseSpec.new
      spec.default!(root_spec)

      @skip_hierarchy.times {
        prev_spec, spec = spec, BaseSpec.new
        spec.default!(prev_spec)
      }

      XMLStreamin::XMLStreamListener.new(spec)
    end

    def define_spec(element, field, config, arg)
      spec = ElementSpec.new(element, field, config)
      arg.is_a?(Hash) ? spec.specs!(arg) : spec.default!(SubElementSpec.new(spec))
      spec
    end

    def merge_specs(container, key, spec)
      container.insert!(key => spec) { |_, spec1, spec2|
        if spec1.respond_to?(:specs!)
          spec1.specs!(spec2.respond_to?(:specs) ? spec2.specs : spec2)
          spec1
        else
          spec1.merge(spec2)
        end
      }
    end

    class BaseSpec < XMLStreamin::XMLSpec

      def start(context, name, attrs)
        context
      end

      def text(context, data)
        context
      end

      def done(context, name)
        context
      end

      def empty(context)
        context
      end

    end

    class RecordSpec < BaseSpec

      attr_reader   :block
      attr_accessor :record

      def initialize(&block)
        super()
        @block = block
      end

      def start(context, name, attrs)
        context = super
        self.record = Athena::Record.new(nil, block, true)
        context
      end

      def done(context, name)
        context = super
        record.close
        context
      end

    end

    class ElementSpec < BaseSpec

      attr_reader   :name, :field, :config
      attr_accessor :record

      def initialize(name, field, config)
        super()
        @name, @field, @config = name, field, config
      end

      def start(context, name, attrs)
        context = super
        self.record = Athena::Record[field, config]
        context
      end

      def text(context, data)
        context = super
        record.update(name, data)
        context
      end

    end

    class SubElementSpec < BaseSpec

      extend Forwardable

      # Forward to parent element; need to specify *all* its attributes and methods
      def_delegators :@parent, :name, :field, :config, :record, :start, :text

      def initialize(parent)
        super()
        @parent = parent
        default!(self)
      end

    end

  end

end
