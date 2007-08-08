#--
###############################################################################
#                                                                             #
# A component of prometheus_conv, the prometheus file converter.              #
#                                                                             #
# Copyright (C) 2007 University of Cologne,                                   #
#                    Albertus-Magnus-Platz,                                   #
#                    50932 Cologne, Germany                                   #
#                                                                             #
# Authors:                                                                    #
#     Jens Wille <jens.wille@uni-koeln.de>                                    #
#                                                                             #
# prometheus_conv is free software; you can redistribute it and/or modify it  #
# under the terms of the GNU General Public License as published by the Free  #
# Software Foundation; either version 2 of the License, or (at your option)   #
# any later version.                                                          #
#                                                                             #
# prometheus_conv is distributed in the hope that it will be useful, but      #
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY  #
# or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for #
# more details.                                                               #
#                                                                             #
# You should have received a copy of the GNU General Public License along     #
# with prometheus_conv [*]; if not, write to the Free Software Foundation,    #
# Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.              #
#                                                                             #
# [*] For the complete text of the GNU General Public License see the file    #
#     COPYING or point your browser at <http://www.gnu.org/licenses/gpl.txt>  #
#                                                                             #
###############################################################################
#++

module PrometheusConv

  class Parser

    attr_reader   :config, :spec
    attr_accessor :block

    def initialize(config, spec)
      @config = build_config(config)
      @spec   = PrometheusConv::Specs[spec].new(self)
    end

    def parse(source, &block)
      self.block = block

      spec.parse(source)
      PrometheusConv::Record.records
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
            when Hash
              elements = v[:elements] || v[:element].to_a

              raise ArgumentError, "no elements specified for field #{field}" unless elements.is_a?(Array)
            else
              raise ArgumentError, "illegal value for field #{field}"
          end

          v[:separator] ||= ', '
          v[:string]    ||= ['%s'] * elements.size * v[:separator]
          v[:empty]     ||= '<<EMPTY>>'

          elements.each { |element|
            (hash[element] ||= {})[field] = v
          }

          hash
        end
      }
    end

  end

end
