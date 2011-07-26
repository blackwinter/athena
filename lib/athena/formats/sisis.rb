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

module Athena::Formats

  class Sisis < Base

    RECORD_RE = %r{(\d+).*?:\s*(.*)}

    register_format :in do

      attr_reader :record_element, :config

      def initialize(parser)
        @config = parser.config.dup

        case @record_element = @config.delete(:__record_element)
          when String
            # fine!
          when nil
            raise NoRecordElementError, 'no record element specified'
          else
            raise IllegalRecordElementError, "illegal record element #{@record_element.inspect}"
        end
      end

    end

    def parse(source, &block)
      record, num = nil, 0

      source.each { |line|
        element, value = line.match(RECORD_RE)[1, 2]

        if element == record_element
          record.close if record
          record = Athena::Record.new(value, block)
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
