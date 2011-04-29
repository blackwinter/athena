#--
###############################################################################
#                                                                             #
# A component of athena, the database file converter.                         #
#                                                                             #
# Copyright (C) 2007-2010 University of Cologne,                              #
#                         Albertus-Magnus-Platz,                              #
#                         50923 Cologne, Germany                              #
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
  class Parser

  include Util

  DEFAULT_SEPARATOR = ', '
  DEFAULT_EMPTY     = '<<EMPTY>>'

  attr_reader :config, :spec

  def initialize(config, spec)
    @config = build_config(config)
    @spec   = Formats[:in, spec].new(self)
  end

  def parse(source, &block)
    res = spec.parse(source, &block)
    res.is_a?(Numeric) ? res : Record.records
  end

  private

  def build_config(config)
    hash = {}

    config.each { |field, value|
      if field.to_s =~ /\A__/
        hash[field] = value
      else
        case value
          when String, Array
            elements, value = [*value], {}
          when Hash
            elements = value[:elements] || value[:element].to_a

            raise ArgumentError, "no elements specified for field #{field}" unless elements.is_a?(Array)
          else
            raise ArgumentError, "illegal value for field #{field}"
        end

        separator = value[:separator] || DEFAULT_SEPARATOR

        elements.each { |element|
          verbose(:config) { spit "#{field.to_s.upcase} -> #{element}" }

          (hash[element] ||= {})[field] = {
            :string   => value[:string] || ['%s'] * elements.size * separator,
            :empty    => value[:empty]  || DEFAULT_EMPTY,
            :elements => elements
          }
        }
      end
    }

    hash
  end

  class ConfigError < StandardError
  end

  end
end
