#--
###############################################################################
#                                                                             #
# athena -- Convert database files to various formats                         #
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

require 'athena/version'

# See README.

module Athena

  autoload :Record,  'athena/record'
  autoload :Formats, 'athena/formats'

  extend self

  DEFAULT_SEPARATOR = ', '
  DEFAULT_EMPTY     = '<<EMPTY>>'

  def run(config, spec, format, input, output)
    Formats[:out, format, output].run(
      Formats[:in, spec, build_config(config)],
      input
    )
  end

  def input_formats
    Formats.formats[:in].sort
  end

  def output_formats
    Formats.formats[:out].sort
  end

  def valid_format?(direction, format)
    Formats.valid_format?(direction, format)
  end

  def valid_input_format?(format)
    valid_format?(:in, format)
  end

  def valid_output_format?(format)
    valid_format?(:out, format)
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

end

require 'nuggets/util/pluggable'
Util::Pluggable.load_plugins_for(Athena)
