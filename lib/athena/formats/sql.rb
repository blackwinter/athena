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

require 'strscan'
require 'athena'

module Athena::Formats

  class MYSQL < Base

    attr_reader :sql_parser

    def parse(source, &block)
      columns, table, num = Hash.new { |h, k| h[k] = [] }, nil, 0

      source.each { |line|
        case line = line.chomp
          when /\ACREATE\s+TABLE\s+`(.+?)`/i
            table = $1
          when /\A\s+`(.+?)`/i
            columns[table] << $1 if table
          when /\A\).*;\z/
            table = nil
          when /\AINSERT\s+INTO\s+`(.+?)`\s+VALUES\s*(.*);\z/i
            _columns = columns[$1]
            next if _columns.empty?

            sql_parser.parse($2) { |row|
              Athena::Record.new(nil, block) { |record|
                row.each_with_index { |value, index|
                  column = _columns[index] or next

                  if column == record_element
                    record.instance_variable_set(:@id, value)
                  end

                  record.update(column, value.to_s, config[column])
                }
              }

              num += 1
            }
        end
      }

      num
    end

    private

    def init_in(*)
      @__record_element_ok__ = [String, nil]
      super
      @sql_parser = SQLParser.new
    end

    class SQLParser

      AST = Struct.new(:value)

      def self.parse(input)
        new.parse(input)
      end

      def parse(input)
        @input = StringScanner.new(input)

        rows, block_given = [], block_given?

        while result = parse_row
          row = result.value
          block_given ? yield(row) : rows << row
          break unless @input.scan(/,/)
        end

        @input.scan(/;/)  # optional

        error('Unexpected data') unless @input.eos?

        rows unless block_given
      end

      def parse_row
        return unless @input.scan(/\(/)

        row = []

        while result = parse_value
          row << result.value
          break unless @input.scan(/,/)
        end

        error('Unclosed row') unless @input.scan(/\)/)

        AST.new(row)
      end

      def parse_value
        parse_string ||
        parse_number ||
        parse_keyword
      end

      def parse_string
        return unless @input.scan(/'/)

        string = ''

        while contents = parse_string_content || parse_string_escape
          string << contents.value
        end

        error('Unclosed string') unless @input.scan(/'/)

        AST.new(string)
      end

      def parse_string_content
        if @input.scan(/[^\\']+/)
          AST.new(@input.matched)
        end
      end

      def parse_string_escape
        if @input.scan(/\\[abtnvfr]/)
          AST.new(eval(%Q{"#{@input.matched}"}))
        elsif @input.scan(/\\.|''/)
          AST.new(@input.matched[-1, 1])
        end
      end

      def parse_number
        if @input.scan(/-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]?\d+)?/)
          AST.new(eval(@input.matched))
        end
      end

      def parse_keyword
        if @input.scan(/null/i)
          AST.new(nil)
        end
      end

      def error(message)
        if @input.eos?
          raise "Unexpected end of input (#{message})."
        else
          raise "#{message} at #{$.}:#{@input.pos}: #{@input.peek(16).inspect}"
        end
      end

    end

  end

  class PGSQL < Base

    def parse(source, &block)
      columns, table, num = Hash.new { |h, k| h[k] = [] }, nil, 0

      source.each { |line|
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
