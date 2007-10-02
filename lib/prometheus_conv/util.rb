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
# Software Foundation; either version 3 of the License, or (at your option)   #
# any later version.                                                          #
#                                                                             #
# prometheus_conv is distributed in the hope that it will be useful, but      #
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY  #
# or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for #
# more details.                                                               #
#                                                                             #
# You should have received a copy of the GNU General Public License along     #
# with prometheus_conv. If not, see <http://www.gnu.org/licenses/>.           #
#                                                                             #
###############################################################################
#++

module PrometheusConv

  module Util

    extend self

    def verbose(what, klass = self.class, &block)
      if $_VERBOSE[what]
        klass.send(:define_method, :spit) { |msg|
          warn "*#{what}: #{msg}"
        }
        klass.send(:define_method, :indent) { |*level|
          '  ' * (level.first || 0)
        }

        instance_eval(&block)
      end
    end

  end

end
