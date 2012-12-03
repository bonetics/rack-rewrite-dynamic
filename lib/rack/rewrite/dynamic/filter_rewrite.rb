require_relative 'base'
require 'active_support/all'
module Rack
  class Rewrite
    module Dynamic
      class FilterRewrite
        include Base

        def perform(match, rack_env)
          if !(match[1] =~ /assets/)
            filter_parts = match[1].split(@opts[:separator])
            if filter_parts.present?
              slugs = filter_parts.map do |slug_candidate|
                find_sluggable(slug_candidate)
              end
              if !slugs.include?(nil)
                filter_params = {}
                slugs.each do |s|
                  filter_params["#{s[:sluggable_type].underscore}_ids"] ||= []
                  filter_params["#{s[:sluggable_type].underscore}_ids"] << s[:sluggable_id]
                end
                return "/#{@opts[:target]}?#{filter_params.to_query}"
              end
            end
          else
            rack_env['REQUEST_URI'] || rack_env['PATH_INFO']
          end
        end

        private
          def build_match_string
            match_string = '^'
            match_string << "#{@opts[:prefix]}" if @opts[:prefix]
            match_string << '\/' + "#{filter_string}"
            match_string << "#{@opts[:separator]}#{@opts[:suffix]}" if @opts[:suffix] && @opts[:separator]
            match_string << "\/?$"
            match_string
          end
          def filter_string
            '([^\/]+)'
          end
      end
    end
  end
end

