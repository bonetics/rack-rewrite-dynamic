require_relative 'rewrite'
require_relative 'filter_rewrite'

module Rack
  class Rewrite
    module Dynamic
      class Rewrites
        attr_reader :rewrites
        def initialize &rewrite_block
          instance_eval(&rewrite_block) if block_given?
        end

        def rewrite_filter(opts = {})
          rewrite(opts, FilterRewrite)
        end
        def rewrite(opts = {}, rewrite_klass = Rewrite)
          @rewrites ||= []
          @rewrites << rewrite_klass.new(opts)
        end

        def apply_rewrites(base)
          @rewrites.each do |rewrite|
            rewrite.apply_rewrite(base)
          end
        end
      end
    end
  end
end

