module Rack
  class Rewrite
    module Dynamic
      module Base
        attr_reader :opts
        def initialize(opts)
          @opts = opts
          @opts[:slug_name] ||= 'Slug'
          @opts[:route_generator_name] ||= 'Rack::Rewrite::Dynamic::RailsRouteGenerator'
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
          slug_klass.find(friendly_id)
        rescue ActiveRecord::RecordNotFound
          # :)
        end
        def slug_klass
          @slug_klass ||= @opts[:slug_name].constantize
        end
        def route_generator_klass
          @route_generator_klass ||= @opts[:route_generator_name].constantize
        end
        def slug_path_if_present(slug, rack_env)
          if slug
            route_generator_klass.route_for slug
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

