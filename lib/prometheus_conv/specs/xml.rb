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

  class Specs

    class XML < PrometheusConv::Specs

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

        record_element = config.delete(:record_element)
        raise(NoRecordElementError, 'no record element specified') unless record_element

        field_specs = config.inject({}) { |specs, (field, c)|
          unless c.is_a?(Hash)
            fields = [*c]
            string = ['%s'] * fields.size * ', '

            c = { :fields => fields, :string => string }
          end

          c[:fields].each { |f|
            define_spec = lambda { |arg|
              s = XMLFieldSpec.new(f, field, c[:fields], c[:string])

              case arg
                when Hash
                  s.specs!(arg)
                  #s.default!(XMLDebugSpec.new)
                else
                  s.default!(XMLSubFieldSpec.new(s))
                  #s.default!(XMLDebugSpec.new)
              end

              return s
            }

            merge_specs = lambda { |s1, s2|
              if s1.is_a?(XMLStreamin::XMLSpec)
                s1.specs!(s2.is_a?(XMLStreamin::XMLSpec) ? s2.specs : s2)
                s1
              else
                s1.merge(s2)
              end
            }

            f.split('/').reverse.inject({}) { |hash, part|
              s = define_spec[hash.empty? ? :default : hash]
              hash.insert!(part, s, &merge_specs)
            }.each { |key, s|
              specs.insert!(key, s, &merge_specs)
            }
          }

          specs
        }

        record_spec = XMLRecordSpec.new(parser)
        record_spec.specs!(field_specs)

        root_spec   = XMLVoidSpec.new
        root_spec.specs!(record_element => record_spec)

        spec        = XMLVoidSpec.new
        spec.default!(root_spec)

        spec
      end

      class XMLVoidSpec < XMLStreamin::XMLSpec
      end

      class XMLDebugSpec < XMLStreamin::XMLSpec

        attr_reader :prefix

        def initialize(prefix = 'Element')
          super()

          @prefix = prefix
        end

        def start(context, name, attrs)
          warn "#{prefix}: #{name}"
          attrs.each { |attr|
             warn "  #{attr[0]} = #{attr[1]}"
         }

          return context
        end

      end

      class XMLRecordSpec < XMLStreamin::XMLSpec

        attr_reader   :parser
        attr_accessor :record

        def initialize(parser)
          super()

          @parser = parser
        end

        def start(context, name, attrs)
          self.record = PrometheusConv::Record.new(parser.block)
        end

        def done(context, name)
          record.close
        end

      end

      class XMLFieldSpec < XMLStreamin::XMLSpec

        attr_reader   :name, :field, :fields, :string
        attr_accessor :record

        def initialize(name, field, fields, string)
          super()

          @name   = name
          @field  = field
          @fields = fields
          @string = string
        end

        def start(context, name, attrs)
          self.record = PrometheusConv::Record.record field, fields, string
        end

        def text(context, data)
          record.update name, data
        end

      end

      class XMLSubFieldSpec < XMLStreamin::XMLSpec

        extend Forwardable

        # Forward to parent element; need to specify *all* its attributes and methods
        def_delegators :@parent, :name, :field, :fields, :string, :record, :start, :text

        def initialize(parent)
          super()

          @parent = parent
          default! self
        end

      end

      class NoRecordElementError < StandardError
      end

    end

  end

end
