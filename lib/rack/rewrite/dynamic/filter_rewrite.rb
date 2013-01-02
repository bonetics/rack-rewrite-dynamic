require_relative 'base'
require 'active_support/all'
module Rack
  class Rewrite
    module Dynamic
      class FilterRewrite
        include Base

        def perform(match, rack_env)
          if !(match[1] =~ /assets/)
            filter_params = {}

            @opts[:url_parts].each_with_index do |url_part, index|
              if url_part.keys.include?(:prefix) || url_part.keys.include?(:suffix)
                slug_candidate = match[index+1]
                slug = find_sluggable(slug_candidate)
                add_filter_param(filter_params, slug) if slug
              elsif url_part.keys.include?(:groups)
                slug_groups = match[index+1].match(slug_group_matcher(url_part[:groups]))[1..-1]
                filter_parts = slug_groups.to_a.each_with_index.map { |slug_group, i| slug_group.split(url_part[:groups][i][:separator]) }.flatten

                slugs = filter_parts.map do |candidate|
                  find_sluggable(candidate)
                end
                if !slugs.include?(nil)
                  slugs.each do |s|
                    add_filter_param(filter_params, s)
                  end
                end
              end
            end
            return "/#{@opts[:target]}?#{filter_params.to_query}" if filter_params.length > 0
          else
            rack_env['REQUEST_URI'] || rack_env['PATH_INFO']
          end
        end

        private
          def add_filter_param(filter_params, slug)
            filter_params["#{slug[:sluggable_type].underscore}_ids"] ||= []
            filter_params["#{slug[:sluggable_type].underscore}_ids"] << slug[:sluggable_id]
          end
          def slug_group_matcher(groups)
            match_string = groups.map do |group|
              "#{group[:prefix]}#{filter_string}#{group[:suffix]}"
            end.join
            Regexp.new(match_string)
          end

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

