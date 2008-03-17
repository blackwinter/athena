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

class Athena::Formats

  @formats = { :in => {}, :out => {} }

  class << self

    def formats
      Athena::Formats.instance_variable_get(:@formats)
    end

    def [](direction, format)
      formats[direction][format]
    end

    def valid_format?(direction, format)
      formats[direction].has_key?(format)
    end

    def deferred?
      false
    end

    def convert(*args)
      raise NotImplementedError, 'must be defined by sub-class'
    end

    private

    def register_format(direction, format)
      if existing = formats[direction][format]
        raise DuplicateFormatDefinitionError,
          "format already defined (#{direction}): #{format} = #{existing}"
      end

      formats[direction][format] = self
    end

    def register_formats(direction, *formats)
      formats.each { |format|
        register_format(direction, format)
      }
    end

  end

  def parse(*args)
    raise NotImplementedError, 'must be defined by sub-class'
  end

  class DuplicateFormatDefinitionError < StandardError
  end

  class FormatArgumentError < ArgumentError
  end

end

Dir[__FILE__.sub(/\.rb$/, '/**/*.rb')].each { |rb|
  require rb
}
