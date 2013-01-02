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
            match_string = '^\/'
            match_string << @opts[:url_parts].map do |url_part|
              if url_part.keys.include?(:prefix) || url_part.keys.include?(:suffix)
                "#{url_part[:prefix]}#{filter_string}#{url_part[:suffix]}"
              elsif url_part.keys.include?(:groups)
                filter_string
              end
            end.join(suburl_separator)

            match_string
          end
          def filter_string
            '([^\/]+)'
          end
          def suburl_separator
            '\/'
          end
      end
    end
  end
end

