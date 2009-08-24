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
require 'enumerator'

module Athena::Formats

  class Lingo < Base

    def convert(record)
      record.struct.inject([]) { |terms, (field, struct)|
        terms << struct[:elements].inject([]) { |array, element|
          array += (struct[:values][element] || []).map { |v|
            (v || '').strip.gsub(/(?:\r?\n)+/, ' ')
          }.reject { |v| v.empty? }
        }
      }
    end

    def deferred?
      true
    end

    private

    def check_number_of_arguments(expected, actual, blow = false, &block)
      return true if block ? block[actual] : expected == actual

      msg = "wrong number of arguments for #{self} (#{actual} for #{expected})"

      if blow
        raise FormatArgumentError, msg
      else
        warn msg
        return false
      end
    end

    def check_number_of_arguments!(expected, actual, &block)
      check_number_of_arguments(expected, actual, true, &block)
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
          next unless check_number_of_arguments(2, terms.size)

          terms.join('*')
        }.compact
      end

    end

    # "Essen,essen #v Essen #s Esse #s\n"
    register_format! :out, 'lingo/word_class' do

      def convert(record)
        super.map { |terms|
          next unless check_number_of_arguments('odd, > 1', terms.size) { |actual|
            actual > 1 && actual % 2 == 1
          }

          [terms.shift, terms.to_enum(:each_slice, 2).map { |form, wc|
            "#{form} ##{wc}"
          }.join(' ')].join(',')
        }.compact
      end

    end

    # "Fax;Faxkopie;Telefax\n"
    register_format! :out, 'lingo/multi_value', 'lingo/multi_key' do

      def convert(record)
        super.map { |terms|
          next unless check_number_of_arguments('> 1', terms.size) { |actual|
            actual > 1
          }

          terms.join(';')
        }.compact
      end

    end

  end

end
