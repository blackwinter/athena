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
