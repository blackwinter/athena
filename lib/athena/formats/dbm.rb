#--
###############################################################################
#                                                                             #
# A component of athena, the database file converter.                         #
#                                                                             #
# Copyright (C) 2007-2008 University of Cologne,                              #
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

require 'iconv'

class Athena::Formats

  class DBM < Athena::Formats

    register_formats :out, 'dbm', 'midos'

    CRLF = "\015\012"

    ICONV_TO_LATIN1 = Iconv.new('latin1', 'utf-8')

    VALUE_SEPARATOR  = '|'
    RECORD_SEPARATOR = '&&&'

    def self.convert(record)
      dbm = ["ID:#{record.id}"]

      record.struct.each { |field, struct|
        strings = struct[:elements].inject([]) { |array, element|
          values = (struct[:values][element] || []).map { |v|
            (v || '').strip.gsub(/(?:\r?\n)+/, ' ')
          }.reject { |v| v.empty? }

          array << (values.empty? ? struct[:empty] : values.join(VALUE_SEPARATOR))
        }

        dbm << "#{field.to_s.upcase}:#{ICONV_TO_LATIN1.iconv(struct[:string] % strings)}"
      }

      dbm << RECORD_SEPARATOR

      dbm.join(CRLF) << CRLF << CRLF
    end

  end

end
