module PrometheusConv

  module Util

    extend self

    def verbose(what, klass = self.class, &block)
      if $_VERBOSE[what]
        klass.send(:define_method, :spit) { |msg|
          warn "*#{what}: #{msg}"
        }

        instance_eval(&block)
      end
    end

  end

end
