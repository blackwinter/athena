#--
###############################################################################
#                                                                             #
# A component of athena, the database file converter.                         #
#                                                                             #
# Copyright (C) 2007-2012 University of Cologne,                              #
#                         Albertus-Magnus-Platz,                              #
#                         50923 Cologne, Germany                              #
#                                                                             #
# Copyright (C) 2013-2014 Jens Wille                                          #
#                                                                             #
# Authors:                                                                    #
#     Jens Wille <jens.wille@gmail.com>                                       #
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
require 'midos'

module Athena::Formats

  class DBM < Base

    RECORD_SEPARATOR = ::Midos::DEFAULT_RS
    FIELD_SEPARATOR  = ::Midos::DEFAULT_FS
    VALUE_SEPARATOR  = ::Midos::DEFAULT_VS

    TO_LATIN1 = begin
      require 'iconv'
    rescue LoadError
      Object.new.tap { |x|
        if ENV['ATHENA_DBM_NOCONV']
          def x.iconv(s); s; end
        else
          def x.iconv(s); s.encode('iso-8859-1', 'utf-8'); end
        end
      }
    else
      iconv = Iconv.new('latin1//TRANSLIT//IGNORE', 'utf-8')
      def iconv.iconv(s); s; end if ENV['ATHENA_DBM_NOCONV']
      iconv
    end

    attr_reader :dbm_parser

    def parse(input, &block)
      num = 0

      dbm_parser.parse(input) { |id, doc|
        Athena::Record.new(id, block) { |record|
          config.each { |element, field_config|
            Array(doc[element]).each { |value|
              record.update(element, value, field_config)
            }
          }
        }

        num += 1
      }

      num
    end

    def convert(record)
      rs, fs, vs, crlf_re, iconv =
        RECORD_SEPARATOR, FIELD_SEPARATOR, VALUE_SEPARATOR, CRLF_RE, TO_LATIN1

      dbm = ["ID#{fs}#{record.id}"]

      record.struct.each { |field, struct|
        struct_values = struct[:values]
        struct_values.default = []

        strings = struct[:elements].map { |element|
          values = []

          struct_values[element].each { |value|
            if value
              value = value.strip.gsub(crlf_re, ' ')
              values << value unless value.empty?
            end
          }

          values.empty? ? struct[:empty] : values.join(vs)
        }

        dbm << "#{field.to_s.upcase}#{fs}#{iconv.iconv(struct[:string] % strings)}"
      }

      dbm << rs << CRLF

      dbm.join(CRLF)
    end

    private

    def init_in(*)
      @__record_element_ok__ = [String, nil]
      super
      @dbm_parser = ::Midos::Reader.new(key: record_element)
    end

  end

  Midos = DBM

end
