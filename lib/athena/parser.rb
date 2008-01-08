#--
###############################################################################
#                                                                             #
# A component of athena, the database file converter.                         #
#                                                                             #
# Copyright (C) 2007 University of Cologne,                                   #
#                    Albertus-Magnus-Platz,                                   #
#                    50932 Cologne, Germany                                   #
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

    attr_reader   :config, :spec
    attr_accessor :block

    def initialize(config, spec)
      @config = build_config(config)
      @spec   = Athena::Formats[:in, spec].new(self)
    end

    def parse(source, &block)
      self.block = block

      spec.parse(source)
      Athena::Record.records
    end

    private

    def build_config(config)
      config.inject({}) { |hash, (field, v)|
        if field.to_s =~ /^__/
          hash.merge(field => v)
        else
          case v
            when String, Array
              elements = [*v]
              v = {}
            when Hash
              elements = v[:elements] || v[:element].to_a

              raise ArgumentError, "no elements specified for field #{field}" \
                unless elements.is_a?(Array)
            else
              raise ArgumentError, "illegal value for field #{field}"
          end

          separator = v[:separator] || DEFAULT_SEPARATOR

          elements.each { |element|
            verbose(:config) do
              spit "#{field.to_s.upcase} -> #{element}"
            end

            (hash[element] ||= {})[field] = {
              :string   => v[:string] || ['%s'] * elements.size * separator,
              :empty    => v[:empty]  || DEFAULT_EMPTY,
              :elements => elements
            }
          }

          hash
        end
      }
    end

  end

end
