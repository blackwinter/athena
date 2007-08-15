#--
###############################################################################
#                                                                             #
# A component of prometheus_conv, the prometheus file converter.              #
#                                                                             #
# Copyright (C) 2007 University of Cologne,                                   #
#                    Albertus-Magnus-Platz,                                   #
#                    50932 Cologne, Germany                                   #
#                                                                             #
# Authors:                                                                    #
#     Jens Wille <jens.wille@uni-koeln.de>                                    #
#                                                                             #
# prometheus_conv is free software; you can redistribute it and/or modify it  #
# under the terms of the GNU General Public License as published by the Free  #
# Software Foundation; either version 2 of the License, or (at your option)   #
# any later version.                                                          #
#                                                                             #
# prometheus_conv is distributed in the hope that it will be useful, but      #
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY  #
# or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for #
# more details.                                                               #
#                                                                             #
# You should have received a copy of the GNU General Public License along     #
# with prometheus_conv [*]; if not, write to the Free Software Foundation,    #
# Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.              #
#                                                                             #
# [*] For the complete text of the GNU General Public License see the file    #
#     COPYING or point your browser at <http://www.gnu.org/licenses/gpl.txt>  #
#                                                                             #
###############################################################################
#++

require 'forwardable'

require 'rubygems'

require 'xmlstreamin'
require 'nuggets/hash/insert'

module PrometheusConv

  class Formats

    class XML < PrometheusConv::Formats

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

        record_element = config.delete(:__record_element)
        unless record_element
          raise NoRecordElementError, 'no record element specified'
        else
          raise IllegalRecordElementError, "illegal record element #{record_element}" unless record_element.is_a?(String)
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
          if s1.is_a?(XMLStreamin::XMLSpec)
            s1.specs!(s2.is_a?(XMLStreamin::XMLSpec) ? s2.specs : s2)
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
            spit "#{indent}<#{name}>"
            step :down

            attrs.each { |attr|
              spit "#{indent(1)}[#{attr[0]} = #{attr[1]}]"
            }
          end

          return context
        end

        def text(context, data)
          verbose(:xml) do
            content = data.strip
            spit "#{indent}#{content}" unless content.empty?
          end

          return context
        end

        def done(context, name)
          verbose(:xml) do
            step :up
            spit "#{indent}</#{name}>"
          end

          return context
        end

        def empty(context)
          verbose(:xml) do
            step :up
          end

          return context
        end

        private

        def level
          BaseSpec.instance_variable_get :@level
        end

        def step(direction)
          steps = { :down => 1, :up => -1 }
          BaseSpec.instance_variable_set :@level, level + steps[direction]
        end

        def indent(plus = 0)
          '  ' * (level + plus)
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

          self.record = PrometheusConv::Record.new(parser.block)
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

          self.record = PrometheusConv::Record[field, config]
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
