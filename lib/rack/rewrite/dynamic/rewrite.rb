require_relative 'base'
module Rack
  class Rewrite
    module Dynamic
      class Rewrite
        include Base

        def perform(match, rack_env)
          if !(match[1] =~ /assets/)
            urls = find_urls(match, rack_env)
            if urls.length > 0
              urls.first
            else
              original_path(rack_env)
            end
          else
            original_path(rack_env)
          end
        end

        def find_urls(match, rack_env)
          @opts[:url_parts].map do |url_def|
            find_url(url_def, match, rack_env)
          end.compact
        end

        def find_url(url_parts, match, rack_env)
          scope_slug = nil
          slugs = url_parts.each_with_index.map do |url_part, index|
            if url_part[1] == 'slug'
              scope_slug = slug_type?(match[index+1], url_part[0])
            elsif url_part[1] == 'scoped_slug'
              scope_slug = scoped_slug_type?(match[index+1], url_part[0], scope_slug)
            else
              'static'
            end
          end
          slugs.reject!{|s| s == 'static'}
          if !slugs.include?(nil)
            slug_path_if_present(slugs[url_parts.reject{|k, v| v == 'static' }.length-1], rack_env)
          else
            nil
          end
        end

        private
          def build_match_string
            match_string = "^\/"
            match_string << @opts[:url_parts].first.map do |url_value, url_type|
              if url_type == 'static'
                "(#{url_value})"
              else
                suburl_string
              end
            end.join(suburl_separator)
            match_string << @opts[:suffix] if @opts[:suffix]
            match_string << "\/?$"
            match_string
          end
          def suburl_string
            '([^\/]+)'
          end
          def suburl_separator
            '\/'
          end
      end
    end
  end
end

