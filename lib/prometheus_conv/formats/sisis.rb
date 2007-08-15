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

module PrometheusConv

  class Formats

    class Sisis < PrometheusConv::Formats

      register_format :in, 'sisis'

      attr_reader :record_element, :config, :parser

      def initialize(parser)
        config = parser.config.dup

        case @record_element = config.delete(:__record_element)
          when String
            # fine!
          when nil
            raise NoRecordElementError, 'no record element specified'
          else
            raise IllegalRecordElementError, "illegal record element #{@record_element}"
        end

        @config = config
        @parser = parser
      end

      def parse(source)
        record = nil

        source.each { |line|
          element, value = line.match(/(\d+).*?:\s*(.*)/)[1, 2]

          case element
            when record_element
              record.close if record
              record = PrometheusConv::Record.new(parser.block, value)
            else
              record.update(element, value, config[element])
          end
        }

        record.close if record
      end

      class NoRecordElementError < StandardError
      end

      class IllegalRecordElementError < StandardError
      end

    end

  end

end
