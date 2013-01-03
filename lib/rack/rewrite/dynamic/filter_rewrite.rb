require_relative 'base'
require 'active_support/all'
module Rack
  class Rewrite
    module Dynamic
      class FilterRewrite
        include Base

        def perform(match, rack_env)
          if !(match[1] =~ /assets/)
            filter_parts = parse_filter_parts(match)
            build_return_path(filter_parts, rack_env)
          else
            original_path(rack_env)
          end
        end

        private
          def build_return_path(filter_parts, rack_env)
            if filter_parts.length > 0
              slugs = filter_parts.map do |candidate|
                find_sluggable(candidate)
              end

              filter_params = {}
              if !slugs.include?(nil)
                slugs.each do |s|
                  add_filter_param(filter_params, s)
                end
              end

              return "/#{@opts[:target]}?#{filter_params.to_query}" if filter_params.length > 0
            end
            original_path(rack_env)
          end

          def parse_filter_parts(match)
            slug_index = 0

            @opts[:url_parts].map do |url_part|
              if url_part.keys.include?(:static)
                # :)
              elsif url_part.keys.include?(:prefix) || url_part.keys.include?(:suffix)
                slug_index += 1
                if match[slug_index]
                  match[slug_index].chomp(url_part[:separator])
                end
              elsif url_part.keys.include?(:groups)
                if match[slug_index+1]
                  slug_index += 1
                  match[slug_index..-1].each_with_index.map { |slug_group, i| slug_group.split(url_part[:groups][i][:separator]) if slug_group }.flatten
                end
              end
            end.flatten.compact
          end

          def add_filter_param(filter_params, slug)
            filter_params["#{slug[:sluggable_type].underscore}_ids"] ||= []
            filter_params["#{slug[:sluggable_type].underscore}_ids"] << slug[:sluggable_id]
          end

          def slug_group_matcher_string(groups)
            groups.map do |group|
              "(#{group[:prefix]}#{filter_string}#{group[:suffix]})?-?"
            end.join
          end

          def slug_group_matcher(groups)
            Regexp.new(slug_group_matcher_string(groups))
          end

          def build_match_string
            match_string = '^\/'
            match_string << @opts[:url_parts].map do |url_part|
              if url_part.keys.include?(:static)
                "(#{url_part[:static]})"
              elsif url_part.keys.include?(:prefix) || url_part.keys.include?(:suffix)
                "#{url_part[:prefix]}#{filter_string}#{('?' unless url_part[:required])}#{url_part[:separator]}?#{url_part[:suffix]}"
              elsif url_part.keys.include?(:groups)
                slug_group_matcher_string(url_part[:groups]).to_s
              end + suburl_separator(url_part[:required])
            end.join

            match_string.chomp!(suburl_separator(true))
            match_string.chomp(suburl_separator(false))
          end
          def filter_string
            '(?<slug_groups>[^\/]+)'
          end
          def suburl_separator(required = false)
            "\\/#{'?' unless required}"
          end
      end
    end
  end
end

