#--
###############################################################################
#                                                                             #
# A component of athena, the database file converter.                         #
#                                                                             #
# Copyright (C) 2007-2010 University of Cologne,                              #
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

module Athena
  class Record

  include Util

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
    @id     = id || 2 * object_id.abs + (object_id < 0 ? 0 : 1)
    @block  = block
    @struct = {}

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
    struct[field] ||= config.merge(:values => Hash.new { |h, k| h[k] = [] })
  end

  def update(element, data, field_config = nil)
    if field_config
      field_config.each { |field, config|
        fill(field, config)
      }
    end

    struct.each_key { |field|
      verbose(:data) {
        spit "#{field.to_s.upcase}[#{element}] << #{data.strip}" unless data.strip.empty?
      }

      struct[field][:values][element] << data
    }
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
