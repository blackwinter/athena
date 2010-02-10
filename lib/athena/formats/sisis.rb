#--
###############################################################################
#                                                                             #
# A component of athena, the database file converter.                         #
#                                                                             #
# Copyright (C) 2007-2010 University of Cologne,                              #
#                         Albertus-Magnus-Platz,                              #
#                         50932 Cologne, Germany                              #
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

module Athena
  module Formats

  class Sisis < Base

    register_format :in do

      attr_reader :record_element, :config, :parser

      def initialize(parser)
        config = parser.config.dup

        case @record_element = config.delete(:__record_element)
          when String
            # fine!
          when nil
            raise NoRecordElementError, 'no record element specified'
          else
            raise IllegalRecordElementError, "illegal record element #{@record_element.inspect}"
        end

        @config = config
        @parser = parser
      end

    end

    def parse(source, &block)
      record, num = nil, 0

      source.each { |line|
        element, value = line.match(/(\d+).*?:\s*(.*)/)[1, 2]

        if element == record_element
          record.close if record
          record = Record.new(value, block)
          num += 1
        else
          record.update(element, value, config[element])
        end
      }

      record.close if record

      num
    end

  end

  end
end
