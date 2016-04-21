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

require 'nuggets/integer/map'
require 'athena'

module Athena

  class Record

    @records = []

    class << self

      def records
        @records
      end

      def [](field = nil, config = nil)
        record = records.last
        raise NoRecordError unless record

        record.fill(field, config) if field && config
        record
      end

    end

    attr_reader :struct, :block, :id

    def initialize(id = nil, block = nil, add = !block)
      @id, @block, @struct = id || object_id.map_positive, block, {}

      add_record if add

      if block_given?
        begin
          yield self
        ensure
          close
        end
      end
    end

    def fill(field, config)
      struct[field] ||= config.merge(values: Hash.new { |h, k| h[k] = [] })
    end

    def update(element, data, field_config = nil)
      field_config.each { |field, config| fill(field, config) } if field_config
      struct.each_key { |field| struct[field][:values][element] << data }
    end

    def close
      block ? block[self] : self
    end

    def to(format)
      Formats[:out, format].convert(self)
    end

    private

    def add_record
      self.class.records << self
    end

    class NoRecordError < StandardError
    end

  end

end
