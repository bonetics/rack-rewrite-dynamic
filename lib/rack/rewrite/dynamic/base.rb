module Rack
  class Rewrite
    module Dynamic
      module Base
        attr_reader :opts
        def initialize(opts)
          @opts = opts
        end

        def apply_rewrite(base)
          base.send :rewrite, %r{#{build_match_string}}, lambda { |match, rack_env|
            perform(match, rack_env)
          }
        end

        def slug_type?(slug_name, slug_type)
          slug = find_sluggable(slug_name)
          slug if slug && slug[:sluggable_type] == slug_type
        end
        def find_sluggable(friendly_id)
          Slug.find(friendly_id)
        rescue ActiveRecord::RecordNotFound
          nil
        end
        def slug_path_if_present(slug, rack_env)
          if slug
            Rails.application.routes.url_helpers.send("#{slug[:sluggable_type].underscore}_path", slug[:sluggable_id])
          else
            rack_env['REQUEST_URI'] || rack_env['PATH_INFO']
          end
        end
        def original_path(rack_env)
          rack_env['REQUEST_URI'] || rack_env['PATH_INFO']
        end
      end
    end
  end
end

