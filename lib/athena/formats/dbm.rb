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

require 'iconv'

module Athena
  module Formats

  class DBM < Base

    VALUE_SEPARATOR  = '|'
    RECORD_SEPARATOR = '&&&'

    ICONV_TO_LATIN1 = Iconv.new('latin1//TRANSLIT//IGNORE', 'utf-8')

    register_format :out, 'midos'

    def convert(record)
      dbm = ["ID:#{record.id}"]

      record.struct.each { |field, struct|
        struct_values = struct[:values]
        struct_values.default = []

        strings = struct[:elements].map { |element|
          values = []

          struct_values[element].each { |value|
            if value
              value = value.strip.gsub(CRLF_RE, ' ')
              values << value unless value.empty?
            end
          }

          values.empty? ? struct[:empty] : values.join(VALUE_SEPARATOR)
        }

        dbm << "#{field.to_s.upcase}:#{ICONV_TO_LATIN1.iconv(struct[:string] % strings)}"
      }

      dbm << RECORD_SEPARATOR << CRLF

      dbm.join(CRLF)
    end

  end

  end
end
