#--
###############################################################################
#                                                                             #
# prometheus_conv -- Convert prometheus files to various formats              #
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

require 'prometheus_conv/parser'
require 'prometheus_conv/specs'
require 'prometheus_conv/record'
require 'prometheus_conv/formats'

module PrometheusConv

  extend self

  def parser(config, spec)
    Parser.new(config, spec)
  end

  def specs
    Specs.specs.keys.sort
  end

  def valid_spec?(spec)
    Specs.valid_spec?(spec)
  end

  def formats
    Formats.formats.keys.sort
  end

  def valid_format?(format)
    Formats.valid_format?(format)
  end

end
