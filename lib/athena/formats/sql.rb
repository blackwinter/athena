#--
###############################################################################
#                                                                             #
# A component of athena, the database file converter.                         #
#                                                                             #
# Copyright (C) 2007-2012 University of Cologne,                              #
#                         Albertus-Magnus-Platz,                              #
#                         50923 Cologne, Germany                              #
#                                                                             #
# Copyright (C) 2013 Jens Wille                                               #
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

module Athena::Formats

  class MYSQL < Base

    attr_reader :sql_parser

    def parse(input, &block)
      num = 0

      sql_parser.parse(input) { |event, *args|
        if event == :insert
          _, _, columns, values = args

          Athena::Record.new(nil, block) { |record|
            values.each_with_index { |value, index|
              if column = columns[index]
                if column == record_element
                  record.instance_variable_set(:@id, value)
                end

                record.update(column, value.to_s, config[column])
              end
            }
          }

          num += 1
        end
      }

      num
    end

    private

    def init_in(*)
      @__record_element_ok__ = [String, nil]
      super
      @sql_parser = Util::MySQL::Parser.new
    end

  end

  class PGSQL < Base

    def parse(input, &block)
      columns, table, num = Hash.new { |h, k| h[k] = [] }, nil, 0

      input.each { |line|
        case line = line.chomp
          when /\ACOPY\s+(\S+)\s+\((.+?)\)\s+FROM\s+stdin;\z/i
            columns[table = $1] = $2.split(/\s*,\s*/)
          when /\A\\\.\z/
            table = nil
          else
            next unless table

            cols = columns[table]
            next if cols.empty?

            Athena::Record.new(nil, block) { |record|
              line.split(/\t/).each_with_index { |value, index|
                column = cols[index] or next

                if column == record_element
                  record.instance_variable_set(:@id, value)
                end

                record.update(column, value, config[column])
              }
            }

            num += 1
        end
      }

      num
    end

    private

    def init_in(*)
      @__record_element_ok__ = [String, nil]
      super
    end

  end

  class MySQL < MYSQL; private :parse; end
  class PgSQL < PGSQL; private :parse; end

end
