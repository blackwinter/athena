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
require 'enumerator'
require 'athena'

module Athena::Formats

  class Lingo < Base

    KV_SEPARATOR = '*'
    WC_SEPARATOR = ','
    MV_SEPARATOR = ';'

    def convert(record)
      terms = []

      record.struct.each { |field, struct|
        struct_values = struct[:values]
        struct_values.default = []

        values = []

        struct[:elements].each { |element|
          struct_values[element].each { |value|
            if value
              value = value.strip.gsub(CRLF_RE, ' ')
              values << value unless value.empty?
            end
          }
        }

        terms << values
      }

      terms
    end

    def deferred?
      true
    end

    private

    def check_args(expected, actual, &block)
      if block ? block[actual] : expected == actual
        true
      else
        warn "wrong number of arguments for #{self} (#{actual} for #{expected})"
        false
      end
    end

    # "Nasenbär\n"
    register_format! :out, 'lingo/single_word' do

      def convert(record)
        super.flatten
      end

    end

    # "John Vorhauer*Vorhauer, John\n"
    register_format! :out, 'lingo/key_value' do

      def convert(record)
        super.map { |terms|
          terms.join(KV_SEPARATOR) if check_args(2, terms.size)
        }.compact
      end

    end

    # "Essen,essen #v Essen #s Esse #s\n"
    register_format! :out, 'lingo/word_class' do

      def convert(record)
        super.map { |terms|
          [ terms.shift,
            terms.to_enum(:each_slice, 2).map { |w, c| "#{w} ##{c}" }.join(' ')
          ].join(WC_SEPARATOR) if check_args('odd, > 1', terms.size) { |actual|
            actual > 1 && actual % 2 == 1
          }
        }.compact
      end

    end

    # "Fax;Faxkopie;Telefax\n"
    register_format! :out, 'lingo/multi_value', 'lingo/multi_key' do

      def convert(record)
        super.map { |terms|
          terms.join(MV_SEPARATOR) if check_args('> 1', terms.size) { |actual|
            actual > 1
          }
        }.compact
      end

    end

  end

end
