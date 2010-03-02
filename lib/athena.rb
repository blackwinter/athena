#--
###############################################################################
#                                                                             #
# athena -- Convert database files to various formats                         #
#                                                                             #
# Copyright (C) 2007-2008 University of Cologne,                              #
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

# Athena is a library to convert (mainly) prometheus database files to various
# output formats. It's accompanied by a corresponding script that gives access
# to all its converting features.
#
# In order to support additional input and/or output formats, Athena::Formats::Base
# needs to be sub-classed and, respectively, an instance method _parse_ or an
# instance method _convert_ supplied. This way, a specific format can even function
# as both input and output format.

module Athena
end

require 'athena/util'
require 'athena/parser'
require 'athena/record'
require 'athena/formats'
require 'athena/version'

module Athena

  extend self

  def parser(config, format)
    Parser.new(config, format)
  end

  def input_formats
    Formats::Base.formats[:in].sort
  end

  def valid_input_format?(format)
    Formats::Base.valid_format?(:in, format)
  end

  def output_formats
    Formats::Base.formats[:out].sort
  end

  def valid_output_format?(format)
    Formats::Base.valid_format?(:out, format)
  end

  def deferred_output?(format)
    Formats[:out, format].deferred?
  end

  def raw_output?(format)
    Formats[:out, format].raw?
  end

  def with_format(format, *args, &block)
    Formats[:out, format].wrap(*args, &block)
  end

end
