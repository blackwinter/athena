#--
###############################################################################
#                                                                             #
# A component of athena, the database file converter.                         #
#                                                                             #
# Copyright (C) 2007 University of Cologne,                                   #
#                    Albertus-Magnus-Platz,                                   #
#                    50932 Cologne, Germany                                   #
#                                                                             #
# Authors:                                                                    #
#     Jens Wille <jens.wille@uni-koeln.de>                                    #
#                                                                             #
# athena is free software; you can redistribute it and/or modify it under the #
# terms of the GNU General Public License as published by the Free Software   #
# Foundation; either version 3 of the License, or (at your option) any later  #
# version.                                                                    #
#                                                                             #
# athena is distributed in the hope that it will be useful, but WITHOUT ANY   #
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS   #
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more       #
# details.                                                                    #
#                                                                             #
# You should have received a copy of the GNU General Public License along     #
# with athena. If not, see <http://www.gnu.org/licenses/>.                    #
#                                                                             #
###############################################################################
#++

require 'forwardable'

require 'rubygems'

require 'xmlstreamin'
require 'nuggets/hash/insert'

module Athena

  class Formats

    class XML < Athena::Formats

      include Util

      register_format :in, 'xml'

      attr_reader :spec, :listener

      def initialize(parser)
        @spec     = build_spec(parser)
        @listener = XMLStreamin::XMLStreamListener.new(@spec)
      end

      def parse(source)
        REXML::Document.parse_stream(source, listener)
      end

      private

      def build_spec(parser)
        config = parser.config.dup

        case record_element = config.delete(:__record_element)
          when String
            # fine!
          when nil
            raise NoRecordElementError, 'no record element specified'
          else
            raise IllegalRecordElementError, "illegal record element #{record_element}"
        end

        element_specs = config.inject({}) { |specs, (element, element_spec)|
          element_spec.each { |field, c|
            element.split('/').reverse.inject({}) { |hash, part|
              s = define_spec(element, field, c, hash.empty? ? :default : hash)
              merge_specs(hash, part, s)
            }.each { |key, s|
              merge_specs(specs, key, s)
            }
          }

          specs
        }

        record_spec = RecordSpec.new(parser)
        record_spec.specs!(element_specs)

        root_spec   = BaseSpec.new
        root_spec.specs!(record_element => record_spec)

        spec        = BaseSpec.new
        spec.default!(root_spec)

        verbose(:spec, BaseSpec) do
          spec.inspect_spec
        end

        spec
      end

      def define_spec(element, field, config, arg)
        spec = ElementSpec.new(element, field, config)

        case arg
          when Hash
            spec.specs!(arg)
          else
            spec.default!(SubElementSpec.new(spec))
        end

        spec
      end

      def merge_specs(container, key, spec)
        container.insert!(key, spec) { |s1, s2|
          if s1.respond_to?(:specs!)
            s1.specs!(s2.respond_to?(:specs) ? s2.specs : s2)
            s1
          else
            s1.merge(s2)
          end
        }
      end

      class BaseSpec < XMLStreamin::XMLSpec

        include Util

        @level = 0

        def start(context, name, attrs)
          verbose(:xml) do
            spit "#{indent(level)}<#{name}>"
            step :down

            attrs.each { |attr|
              spit "#{indent(level + 1)}[#{attr[0]} = #{attr[1]}]"
            }
          end

          return context
        end

        def text(context, data)
          verbose(:xml) do
            content = data.strip
            spit "#{indent(level)}#{content}" unless content.empty?
          end

          return context
        end

        def done(context, name)
          verbose(:xml) do
            step :up
            spit "#{indent(level)}</#{name}>"
          end

          return context
        end

        def empty(context)
          verbose(:xml) do
            step :up
          end

          return context
        end

        def inspect_spec(element = nil, level = 0)
          if respond_to?(:field)
            msg = "#{indent(level)}[#{element}] #{field.to_s.upcase} -> #{name}"
            respond_to?(:spit) ? spit(msg) : warn(msg)
            specs.each { |e, s|
              s.inspect_spec(e, level + 1)
            }
          else
            if specs.empty?
              specs.default.inspect_spec('?', level)
            else
              specs.each { |e, s|
                s.inspect_spec(e, level)
              }
            end
          end
        end

        private

        def level
          BaseSpec.instance_variable_get :@level
        end

        def step(direction)
          steps = { :down => 1, :up => -1 }
          BaseSpec.instance_variable_set :@level, level + steps[direction]
        end

      end

      class RecordSpec < BaseSpec

        attr_reader   :parser
        attr_accessor :record

        def initialize(parser)
          super()

          @parser = parser
        end

        def start(context, name, attrs)
          super

          self.record = Athena::Record.new(parser.block)
        end

        def done(context, name)
          super

          record.close
        end

      end

      class ElementSpec < BaseSpec

        attr_reader   :name, :field, :config
        attr_accessor :record

        def initialize(name, field, config)
          super()

          @name   = name
          @field  = field
          @config = config
        end

        def start(context, name, attrs)
          super

          self.record = Athena::Record[field, config]
        end

        def text(context, data)
          super

          record.update name, data
        end

      end

      class SubElementSpec < BaseSpec

        extend Forwardable

        # Forward to parent element; need to specify *all* its attributes and methods
        def_delegators :@parent, :name, :field, :config, :record, :start, :text

        def initialize(parent)
          super()

          @parent = parent
          default! self
        end

      end

      class NoRecordElementError < StandardError
      end

      class IllegalRecordElementError < StandardError
      end

    end

  end

end
