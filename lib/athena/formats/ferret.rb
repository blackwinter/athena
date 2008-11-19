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

require 'rubygems'
require 'ferret'

class Athena::Formats

  class Ferret < Athena::Formats

    register_format :in, 'ferret'

    attr_reader :record_element, :config, :parser, :match_all_query

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
      path = source.path
      raise "index not found: #{path}" unless File.readable?(File.join(path, 'segments'))

      index = ::Ferret::Index::IndexReader.new(path)

      0.upto(index.max_doc - 1) { |i|
        doc = index[i]

        record = Athena::Record.new(parser.block, doc[record_element])

        config.each { |element, field_config|
          record.update(element, doc[element], field_config)
        }

        record.close
      }

      index.num_docs
    end

    private

    class NoRecordElementError < StandardError
    end

    class IllegalRecordElementError < StandardError
    end

  end

end
