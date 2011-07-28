#--
###############################################################################
#                                                                             #
# A component of athena, the database file converter.                         #
#                                                                             #
# Copyright (C) 2007-2011 University of Cologne,                              #
#                         Albertus-Magnus-Platz,                              #
#                         50923 Cologne, Germany                              #
#                                                                             #
# Authors:                                                                    #
#     Jens Wille <jens.wille@uni-koeln.de>                                    #
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

require 'athena'

if ferret_version = ENV['FERRET_VERSION']
  require 'rubygems'
  gem 'ferret', ferret_version
end

begin
  require 'ferret'
rescue LoadError => err
  warn "ferret#{" #{ferret_version}" if ferret_version} not available (#{err})"
end

module Athena::Formats

  class Ferret < Base

    def parse(source, &block)
      path = source.path

      # make sure the index can be opened
      begin
        File.open(File.join(path, 'segments')) {}
      rescue Errno::ENOENT, Errno::EACCES => err
        raise "can't open index at #{path} (#{err.to_s.sub(/ - .*/, '')})"
      end

      index = ::Ferret::Index::IndexReader.new(path)
      first, last = 0, index.max_doc - 1

      # make sure we can read from the index
      begin
        index[first]
        index[last]
      rescue StandardError  # EOFError, "Not available", ...
        raise "possible Ferret version mismatch; try to set the " <<
              "FERRET_VERSION environment variable to something " <<
              "other than #{Ferret::VERSION}"
      end

      first.upto(last) { |i|
        unless index.deleted?(i)
          doc = index[i]

          Athena::Record.new(doc[record_element], block) { |record|
            config.each { |element, field_config|
              record.update(element, doc[element], field_config)
            }
          }
        end
      }

      index.num_docs
    end

    private :parse unless Object.const_defined?(:Ferret)

  end

end
