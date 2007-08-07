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

require 'iconv'

module PrometheusConv

  class Formats

    class DBM < PrometheusConv::Formats

      register_format 'midos'

      CRLF = "\015\012"

      ICONV_TO_LATIN1 = Iconv.new('latin1', 'utf-8')

      def self.convert(record)
        dbm = ["ID:#{record.object_id.abs}"]
        record.struct.each { |field, struct|
          strings = struct[:elements].inject([]) { |array, element|
            value = (struct[:values][element] || []).map { |v|
              (v || '').strip.gsub(/(?:\r?\n)+/, ' ')
            }.reject { |v| v.empty? }.join('|')

            array << (value.empty? ? struct[:empty] : value)
          }

          dbm << "#{field.to_s.upcase}:#{ICONV_TO_LATIN1.iconv(struct[:string] % strings)}"
        }
        dbm << '&&&'

        dbm.join(CRLF) << CRLF << CRLF
      end

    end

  end

end
