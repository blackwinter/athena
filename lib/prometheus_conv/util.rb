module PrometheusConv

  module Util

    extend self

    def verbose(what, &block)
      if $_VERBOSE[what]
        self.class.send(:define_method, :spit) { |msg|
          warn "*#{what}: #{msg}"
        }

        instance_eval(&block)
      end
    end

  end

end
